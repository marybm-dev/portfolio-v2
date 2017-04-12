import Vapor
import HTTP
import Auth
import Fluent

final class ProjectController {
    
    func addRoutes(drop: Droplet) {
        let portfolio = drop.grouped("portfolio")
        portfolio.get(handler: gridView)
        portfolio.get(String.self, handler: filteredProjects)
        
        let basic = drop.grouped("projects")
        basic.get(handler: index)
        basic.post(handler: create)
        basic.delete(Project.self, handler: delete)
        basic.post(Project.self, "tags", Tag.self, handler: joinTag)
        basic.post(Project.self, "types", Type.self, handler: joinType)
        basic.get(Project.self, "tags", handler: tagsIndex)
        basic.get(Project.self, handler: show)
    }
    
    func index(request: Request) throws -> ResponseRepresentable {
        let projects = try Project.all().makeNode()
        let parameters = try Node(node: [
                "projects": projects,
        ])
        return try drop.view.make("index", parameters)
    }

    func create(request: Request) throws -> ResponseRepresentable {
        guard let title = request.data["title"]?.string,
            let description = request.data["description"]?.string,
            let type = request.data["type"]?.string else {
                throw Abort.badRequest
        }
        
        let image = request.data["image"]?.string
        let video = request.data["video"]?.string
        let link = request.data["link"]?.string
        
        var project = Project(title: title, description: description, type: type, image: image, video: video, link: link)
        try project.save()
        
        return Response(redirect: "/projects")
    }
    
    func show(request: Request, project: Project) throws -> ResponseRepresentable {
        return project
    }
    
    func delete(request: Request, project: Project) throws ->ResponseRepresentable {
        try project.delete()
        return Response(redirect: "/projects")
    }
    
    // Public facing routes
    func gridView(request: Request) throws -> ResponseRepresentable {
        let projects = try Project.all().makeNode(context: ProjectContext.all)
        
        let parameters = try Node(node: [
            "projects": projects,
            ])
        return try drop.view.make("grid", parameters)
    }
    
    func filteredProjects(request: Request, type: String) throws -> ResponseRepresentable {
        let projects = try Project.query().filter("type", type).all().makeNode(context: ProjectContext.all)
        //let projects = try Project.all().makeNode(context: ProjectContext.all)
        
        let parameters = try Node(node: [
            "projects": projects,
            ])
        return try drop.view.make("grid", parameters)
    }
    
    // Private facing routes
    func adminIndexView(request: Request) throws -> ResponseRepresentable {
        let projects = try Project.all().makeNode()
        let parameters = try Node(node: [
            "projects": projects,
            ])
        return try drop.view.make("admin-index", parameters)
    }

    func joinTag(request: Request, project: Project, tag: Tag) throws -> ResponseRepresentable {
        var pivot = Pivot<Project, Tag>(project, tag)
        try pivot.save()
        return project
    }
    
    func joinType(request: Request, project: Project, type: Type) throws -> ResponseRepresentable {
        var pivot = Pivot<Project, Type>(project, type)
        try pivot.save()
        return project
    }
    
    func tagsIndex(request: Request, project: Project) throws -> ResponseRepresentable {
        let tags = try project.tags()
        return try JSON(node: tags.makeNode())
    }
}
