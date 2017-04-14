import Vapor
import HTTP

final class TagController {
    
    func addRoutes(drop: Droplet) {
        let basic = drop.grouped("tags")
        basic.get(handler: index)
        basic.get(Tag.self, "projects", handler: projectsIndex)
    }
    
    func index(request: Request) throws -> ResponseRepresentable {
        let tags = try Tag.all()
        let parameters = try Node(node: [
            "tags": tags.makeNode(),
            ])
        return try drop.view.make("tags", parameters)
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        guard let type = request.data["type"]?.string,
            let name = request.data["name"]?.string else {
                return Response(redirect: "/admin/tags")
        }

        var tag = Tag(type: type, name: name)
        try tag.save()
        return Response(redirect: "/admin/tags")
    }
    
    func delete(request: Request, tag: Tag) throws -> ResponseRepresentable {
        try tag.delete()
        return Response(redirect: "/admin/tags")
    }
    
    func projectsIndex(request: Request, tag: Tag) throws -> ResponseRepresentable {
        let projects = try tag.projects().makeNode(context: ProjectContext.all)
        
        let parameters = try Node(node: [
            "projects": projects,
            ])
        
        return try drop.view.make("portfolio", parameters)
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
