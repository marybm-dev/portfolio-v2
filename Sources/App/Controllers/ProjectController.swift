import Vapor
import HTTP
import Auth

final class ProjectController {
    
    func addRoutes(drop: Droplet) {
        drop.get("projects", handler: indexView)
        drop.post("project", handler: addProject)
        drop.post("project", Project.self, "delete", handler: deleteProject)
    }
    
    func indexView(request: Request) throws -> ResponseRepresentable {
        let projects = try Project.all().makeNode()
        let parameters = try Node(node: [
                "projects": projects,
        ])
        return try drop.view.make("index", parameters)
    }
    
    func adminIndexView(request: Request) throws -> ResponseRepresentable {
        let projects = try Project.all().makeNode()
        let parameters = try Node(node: [
            "projects": projects,
            ])
        return try drop.view.make("admin-index", parameters)
    }
    
    func addProject(request: Request) throws -> ResponseRepresentable {
        
        guard let title = request.data["title"]?.string,
            let description = request.data["description"]?.string,
            let tech = request.data["tech"]?.string,
            let type = request.data["type"]?.string else {
                throw Abort.badRequest
        }
        
        let image = request.data["image"]?.string
        let video = request.data["video"]?.string
        let link = request.data["link"]?.string
        
        var project = Project(title: title, description: description, tech: tech, type: type, image: image, video: video, link: link)
        try project.save()
        
        return Response(redirect: "/projects")
    }
    
    func deleteProject(request: Request, project: Project) throws ->ResponseRepresentable {
        try project.delete()
        return Response(redirect: "/projects")
    }
}
