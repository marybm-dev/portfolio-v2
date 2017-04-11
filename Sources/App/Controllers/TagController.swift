import Vapor
import HTTP

final class TagController {
    
    func addRoutes(drop: Droplet) {
        let basic = drop.grouped("groups")
        basic.get(handler: index)
        basic.post(handler: create)
        basic.delete(Tag.self, handler: delete)
        basic.get(Tag.self, "projects", handler: projectsIndex)
    }
    
    func index(request: Request) throws -> ResponseRepresentable {
        return try JSON(node: Tag.all().makeNode())
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        var tag = try request.tag()
        try tag.save()
        return tag
    }
    
    func delete(request: Request, tag: Tag) throws -> ResponseRepresentable {
        try tag.delete()
        return JSON([:])
    }
    
    func projectsIndex(request: Request, tag: Tag) throws -> ResponseRepresentable {
        let projects = try tag.projects()
        return try JSON(node: projects.makeNode())
    }
}

extension Request {
    func tag() throws -> Tag {
        guard let json = json else {
            throw Abort.badRequest
        }
        return try Tag(node: json)
    }
}
