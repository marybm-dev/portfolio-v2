import Vapor
import HTTP
import Auth
import Fluent

final class ProjectController {
    
    func addRoutes(drop: Droplet) {
        // portfolio routes
        drop.get(handler: projects)
        drop.get(String.self, handler: filteredProjects)
        drop.get(Project.self, handler: project)

        // admin routes
        let basic = drop.grouped("projects")
        basic.post(Project.self, "tags", Tag.self, handler: joinTag)
        basic.get(Project.self, "tags", handler: tagsIndex)
        basic.post(Project.self, "tags-delete", Tag.self, handler: deleteJoinTag)
        basic.post(Project.self, "media-delete", Media.self, handler: deleteMedia)
    }
    
    func index(request: Request) throws -> ResponseRepresentable {
        return try allProjects()
    }

    func new(request: Request) throws -> ResponseRepresentable {
        return try drop.view.make("/private/create")
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        guard let title = request.data["title"]?.string,
            let subtitle = request.data["subtitle"]?.string,
            let description = request.data["description"]?.string,
            let type = request.data["type"]?.string else {
                throw Abort.badRequest
        }
        
        let store = request.data["store"]?.string
        let image = request.data["image"]?.string
        let link = request.data["link"]?.string
        
        var project = Project(title: title, subtitle: subtitle, description: description, type: type, image: image, store: store, link: link)
        try project.save()
        
        return try allProjects()
    }
    
    func show(request: Request, project: Project) throws -> ResponseRepresentable {
        let tags = try Tag.all().makeNode()
        let parameters = try Node(node: [
            "project": project.makeNode(context: ProjectContext.all),
            "tags": tags,
            ])
        return try drop.view.make("/private/show", parameters)
    }
    
    func edit(request: Request, project: Project) throws -> ResponseRepresentable {
        let tags = try Tag.all().makeNode()
        let parameters = try Node(node: [
            "project": project.makeNode(context: ProjectContext.all),
            "tags": tags,
            ])
        
        return try drop.view.make("/private/edit", parameters)
    }
    
    func update(request: Request, project: Project) throws -> ResponseRepresentable {
        guard let projectId = project.id,
            let title = request.data["title"]?.string,
            let subtitle = request.data["subtitle"]?.string,
            let description = request.data["description"]?.string,
            let type = request.data["type"]?.string,
            var project = try Project.query().filter("id", projectId).first() else {
                throw Abort.badRequest
        }
        
        let store = request.data["store"]?.string
        let image = request.data["image"]?.string
        let link = request.data["link"]?.string
        
        project.title = title
        project.subtitle = subtitle
        project.description = description
        project.type = type
        project.image = image
        project.store = store
        project.link = link
        try project.save()
        
        return try allProjects()
    }
    
    func delete(request: Request, project: Project) throws ->ResponseRepresentable {
        try project.delete()
        return try allProjects()
    }

    func allProjects() throws -> ResponseRepresentable {
        let projects = try Project.all().makeNode()
        let parameters = try Node(node: [
            "projects": projects.makeNode(context: ProjectContext.all),
            ])
        return try drop.view.make("/private/index", parameters)
    }
    
}

// Public Portfolio
extension ProjectController {

    func project(request: Request, project: Project) throws -> ResponseRepresentable {
        let parameters = try Node(node: [
            "project": project.makeNode(context: ProjectContext.all),
            "medias": project.medias().makeNode(),
            ])
        return try drop.view.make("/public/project", parameters)
    }
    
    func projects(request: Request) throws -> ResponseRepresentable {
        let projects = try Project.all().makeNode(context: ProjectContext.all)
        
        let parameters = try Node(node: [
            "projects": projects,
            ])
        return try drop.view.make("/public/portfolio", parameters)
    }
    
    func filteredProjects(request: Request, type: String) throws -> ResponseRepresentable {
        let projects = try Project.query().filter("type", type).all().makeNode(context: ProjectContext.all)
        
        let parameters = try Node(node: [
            "projects": projects,
            ])
        return try drop.view.make("/public/portfolio", parameters)
    }
    
}


// Admin Routes {
extension ProjectController {
    
    func joinTag(request: Request, project: Project, tag: Tag) throws -> ResponseRepresentable {
        var pivot = Pivot<Project, Tag>(project, tag)
        try pivot.save()
        
        guard let projectId = project.id,
            let id = projectId.string else {
            throw Abort.badRequest
        }
        return Response(redirect: "/admin/projects/\(id)")
    }
    
    func deleteJoinTag(request: Request, project: Project, tag: Tag) throws -> ResponseRepresentable {
        guard let tagId = tag.id,
            let projectId = project.id,
            let id = projectId.string else {
            throw Abort.badRequest
        }
        
        let pivot = try Pivot<Project, Tag>.query().filter("project_id", projectId).filter("tag_id", tagId).first()
        try pivot?.delete()
        
        return Response(redirect: "/admin/projects/\(id)")
    }
    
    func tagsIndex(request: Request, project: Project) throws -> ResponseRepresentable {
        let tags = try project.tags()
        return try JSON(node: tags.makeNode())
    }
    
    func deleteMedia(request: Request, project: Project, media: Media) throws -> ResponseRepresentable {
        guard let mediaId = media.id,
            let projectId = project.id,
            let id = projectId.string else {
                throw Abort.badRequest
        }
        
        let media = try Media.query().filter("id", mediaId).first()
        try media?.delete()
        
        return Response(redirect: "/admin/projects/\(id)")
    }
}
