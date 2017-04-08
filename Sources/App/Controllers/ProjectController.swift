import Vapor
import HTTP

final class ProjectController {
    
    func addRoutes(drop: Droplet) {
        drop.get("projects", handler: indexView)
    }
    
    func indexView(request: Request) throws -> ResponseRepresentable {
        let projects = try Project.all().makeNode()
        let parameters = try Node(node: [
                "projects": projects,
        ])
        return try drop.view.make("index", parameters)
    }
}
