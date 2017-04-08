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

drop.run()
