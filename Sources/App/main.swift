import Vapor
import VaporPostgreSQL
import Auth
import Sessions
import Fluent

let drop = Droplet()

// Enable Sessions
let memory = MemorySessions()
let sessions = SessionsMiddleware(sessions: memory)

// Droplet configuration
try drop.addProvider(VaporPostgreSQL.Provider)
drop.preparations += Project.self
drop.preparations += User.self
drop.preparations += Tag.self
drop.preparations += Pivot<Project, Tag>.self

drop.middleware += AuthMiddleware<User>()
drop.middleware += TrustProxyMiddleware()
drop.middleware += sessions

// ** FOR DEVELOPMENT ONLY ** Disable Cache
(drop.view as? LeafRenderer)?.stem.cache = nil


// Root route
drop.get { req in
    return try drop.view.make("welcome", [
        "message": drop.localization[req.lang, "welcome", "title"]
        ])
}

// Add public routes
let projectController = ProjectController()
projectController.addRoutes(drop: drop)

let tagController = TagController()
tagController.addRoutes(drop: drop)


// Add admin routes
drop.group("admin") { admin in
    let usersController = UsersController()
    
    // Registration
    admin.post("register", handler: usersController.register)
    
    // Log In
    admin.get("login") { request in
        return  try drop.view.make("login")
    }
    admin.post("login", handler: usersController.login)
    
    // Log Out
    admin.post("logout", handler: usersController.logout)
    
    // Secured Endpoints
    let protect = ProtectMiddleware(error: Abort.custom(status: .unauthorized, message: "Unauthorized"))
    admin.group(BasicAuthMiddleware(), protect) { secured in
        secured.get("me", handler: usersController.me)
        secured.get("projects", handler: projectController.adminIndexView)
    }
}



// Sample routes for filtering Projects
drop.get("mobile") { request in
    return try JSON(node: Project.query().filter("type", "Mobile").all().makeNode())
}

drop.get("web") { request in
    return try JSON(node: Project.query().filter("type", "Web").all().makeNode())
}

drop.get("not-web") { request in
    return try JSON(node: Project.query().filter("type", .notEquals, "Web").all().makeNode())
}

drop.run()
