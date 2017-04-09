import Vapor
import VaporPostgreSQL
import Auth

// Droplet configuration
let drop = Droplet()
try drop.addProvider(VaporPostgreSQL.Provider)
drop.preparations += Project.self
drop.preparations += User.self
drop.middleware += AuthMiddleware<User>()
drop.middleware += TrustProxyMiddleware()

// Disable Cache
(drop.view as? LeafRenderer)?.stem.cache = nil

// Add public Project routes
let projectController = ProjectController()
projectController.addRoutes(drop: drop)


//// Add protected Project routes
let error = Abort.custom(status: .forbidden, message: "Invalid credentials")
let protect = ProtectMiddleware(error: error)
//drop.group(protect) { secure in
//    secure.post("project", handler: projectController.addProject)
//    secure.post("project", Project.self, "delete", handler: projectController.deleteProject)
//}

drop.get { req in
    return try drop.view.make("welcome", [
        "message": drop.localization[req.lang, "welcome", "title"]
        ])
}


drop.group("api") { api in
    api.group("v1") { v1 in
        
        let usersController = UsersController()
        
        // Registration
        v1.post("register", handler: usersController.register)
        
        // Log In
        v1.post("login", handler: usersController.login)
        
        // Log Out
        v1.post("logout", handler: usersController.logout)
        
        // Secured Endpoints
        let protect = ProtectMiddleware(error: Abort.custom(status: .unauthorized, message: "Unauthorized"))
        v1.group(BasicAuthMiddleware(), protect) { secured in
            secured.get("me", handler: usersController.me)
        }
    }
}



//drop.group(protect) { authed in
//    authed.get("mobile") { req in
//        
//        
//        print(req)
//        
//        guard let login = req.data["username"]?.string,
//            let password = req.data["password"]?.string else {
//                throw Abort.badRequest
//        }
//        
//        let credentials = APIKey(id: login, secret: password)
//        try req.auth.login(credentials)
//        return try JSON(node: Project.query().filter("type", "Mobile").all().makeNode())
//    }
//}


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
