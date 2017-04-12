import Vapor
import HTTP

final class TagController {
    
    func addRoutes(drop: Droplet) {
        let basic = drop.grouped("tags")
        basic.get(handler: index)
        basic.post(handler: create)
        basic.delete(Tag.self, handler: delete)
        basic.get(Tag.self, "projects", handler: projectsIndex)
    }
    
    func index(request: Request) throws -> ResponseRepresentable {
        return try JSON(node: Tag.all().makeNode())
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        guard let type = request.data["type"]?.string,
            let name = request.data["name"]?.string else {
                throw Abort.badRequest
        }

        var tag = Tag(type: type, name: name)
        try tag.save()
        return tag
    }
    
    func delete(request: Request, tag: Tag) throws -> ResponseRepresentable {
        try tag.delete()
        return JSON([:])
    }
    
    func projectsIndex(request: Request, tag: Tag) throws -> ResponseRepresentable {
        let projects = try tag.projects().makeNode(context: ProjectContext.all)
        
        let parameters = try Node(node: [
            "projects": projects,
            ])
        
        return try drop.view.make("portfolio", parameters)
    }
    
//    func projectsIndex(request: Request, tag: Tag) throws -> ResponseRepresentable {
//        let projects = try tag.projects()
//        return try JSON(node: projects.makeNode())
//    }
//    
    
}

extension Request {
    func tag() throws -> Tag {
        guard let json = json else {
            throw Abort.badRequest
        }
        return try Tag(node: json)
    }
}
