import Vapor
import VaporPostgreSQL

let drop = Droplet()
try drop.addProvider(VaporPostgreSQL.Provider)
drop.preparations += Project.self

(drop.view as? LeafRenderer)?.stem.cache = nil

let projectController = ProjectController()
projectController.addRoutes(drop: drop)

drop.get("mobile") { request in
    return try JSON(node: Project.query().filter("type", "Mobile").all().makeNode())
}

drop.get("web") { request in
    return try JSON(node: Project.query().filter("type", "Web").all().makeNode())
}

drop.get("not-web") { request in
    return try JSON(node: Project.query().filter("type", .notEquals, "Web").all().makeNode())
}

//drop.get("version") { request in
//    if let db = drop.database?.driver as? PostgreSQLDriver {
//        let version = try db.raw("SELECT version()")
//        return try JSON(node: version)
//    } else {
//        return "No db connection"
//    }
//}
//
//drop.get { req in
//    return try drop.view.make("welcome", [
//    	"message": drop.localization[req.lang, "welcome", "title"]
//    ])
//}

drop.get("test") { request in
    var project = Project(title: "Orcas",
                          description: "Killer Whales",
                          tech: "RoR",
                          type: "Web",
                          image: nil,
                          video: nil,
                          link: "orcas3401.herokuapp.com")
    try project.save()
    return try JSON(node: Project.all().makeNode())
}


drop.run()
