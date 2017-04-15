import Vapor
import HTTP
import Auth
import Fluent

final class ProjectController {
    
    func addRoutes(drop: Droplet) {
        // portfolio routes
        let portfolio = drop.grouped("portfolio")
        portfolio.get(handler: projects)
        portfolio.get(String.self, handler: filteredProjects)
        
        drop.get("test", handler: test)
        
        // api routes
        let basic = drop.grouped("projects")
        basic.post(Project.self, "tags", Tag.self, handler: joinTag)
        basic.post(Project.self, "types", Type.self, handler: joinType)
        basic.get(Project.self, "tags", handler: tagsIndex)
        basic.post(Project.self, "tags-delete", Tag.self, handler: deleteJoinTag)
        basic.post(Project.self, "types-delete", Type.self, handler: deleteJoinType)
    }
    
    func index(request: Request) throws -> ResponseRepresentable {
        let projects = try Project.all().makeNode()
        let parameters = try Node(node: [
                "projects": projects.makeNode(context: ProjectContext.all),
        ])
        return try drop.view.make("index", parameters)
    }

    func new(request: Request) throws -> ResponseRepresentable {
        return try drop.view.make("create")
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
        
        return Response(redirect: "/admin/projects")
    }
    
    func show(request: Request, project: Project) throws -> ResponseRepresentable {
        let parameters = try Node(node: [
            "project": project.makeNode(context: ProjectContext.all),
            ])
        return try drop.view.make("show", parameters)
    }
    
    func edit(request: Request, project: Project) throws -> ResponseRepresentable {
        let tags = try Tag.all().makeNode()
        let types = try Type.all().makeNode()
        let parameters = try Node(node: [
            "project": project.makeNode(context: ProjectContext.all),
            "tags": tags,
            "types": types,
            ])
        return try drop.view.make("edit", parameters)
    }
    
    func update(request: Request, project: Project) throws -> ResponseRepresentable {
        
        guard let projectId = project.id,
            let title = request.data["title"]?.string,
            let description = request.data["description"]?.string,
            let type = request.data["type"]?.string,
            var project = try Project.query().filter("id", projectId).first() else {
            throw Abort.badRequest
        }
        
        let image = request.data["image"]?.string
        let video = request.data["video"]?.string
        let link = request.data["link"]?.string
        
        project.title = title
        project.description = description
        project.type = type
        project.image = image
        project.video = video
        project.link = link
        try project.save()
        
        return try self.show(request: request, project: project)
    }
    
    func delete(request: Request, project: Project) throws ->ResponseRepresentable {
        try project.delete()
        return Response(redirect: "/admin/projects")
    }

}


// Public Portfolio
extension ProjectController {
    
    func test(request: Request) throws -> ResponseRepresentable {
        let projects = try Project.all().makeNode(context: ProjectContext.all)
        
        let parameters = try Node(node: [
            "projects": projects,
            ])
        return try drop.view.make("testBody", parameters)
    }
    
    func projects(request: Request) throws -> ResponseRepresentable {
        let projects = try Project.all().makeNode(context: ProjectContext.all)
        
        let parameters = try Node(node: [
            "projects": projects,
            ])
        return try drop.view.make("portfolio", parameters)
    }
    
    func filteredProjects(request: Request, type: String) throws -> ResponseRepresentable {
        let projects = try Project.query().filter("type", type).all().makeNode(context: ProjectContext.all)
        //let projects = try Project.all().makeNode(context: ProjectContext.all)
        
        let parameters = try Node(node: [
            "projects": projects,
            ])
        return try drop.view.make("portfolio", parameters)
    }
    
}


// API Routes {
extension ProjectController {
    
    func joinTag(request: Request, project: Project, tag: Tag) throws -> ResponseRepresentable {
        var pivot = Pivot<Project, Tag>(project, tag)
        try pivot.save()
        return try self.edit(request: request, project: project)
    }
    
    func joinType(request: Request, project: Project, type: Type) throws -> ResponseRepresentable {
        var pivot = Pivot<Project, Type>(project, type)
        try pivot.save()
        return try self.edit(request: request, project: project)
    }
    
    func deleteJoinTag(request: Request, project: Project, tag: Tag) throws -> ResponseRepresentable {
        guard let tagId = tag.id,
            let projectId = project.id else {
            throw Abort.badRequest
        }
        
        let pivot = try Pivot<Project, Tag>.query().filter("project_id", projectId).filter("tag_id", tagId).first()
        try pivot?.delete()
        
        return try self.edit(request: request, project: project)
    }
    
    func deleteJoinType(request: Request, project: Project, type: Type) throws -> ResponseRepresentable {
        guard let typeId = type.id,
            let projectId = project.id else {
                throw Abort.badRequest
        }
        
        let pivot = try Pivot<Project, Type>.query().filter("project_id", projectId).filter("type_id", typeId).first()
        try pivot?.delete()
        
        return try self.edit(request: request, project: project)
    }
    
    func tagsIndex(request: Request, project: Project) throws -> ResponseRepresentable {
        let tags = try project.tags()
        return try JSON(node: tags.makeNode())
    }
    
}
