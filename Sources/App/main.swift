import Vapor
import VaporPostgreSQL

let drop = Droplet()
try drop.addProvider(VaporPostgreSQL.Provider)
drop.preparations += Project.self

let projectController = ProjectController()
projectController.addRoutes(drop: drop)


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
//
//drop.get("test") { request in
//    var project = Project(title: "HiveMine",
//                          description: "Blah",
//                          tech: "iOS",
//                          image: nil,
//                          video: nil,
//                          link: nil)
//    try project.save()
//    return try JSON(node: Project.all().makeNode())
//}

//drop.resource("posts", PostController())

drop.run()
