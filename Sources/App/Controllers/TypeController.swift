import Vapor
import HTTP

final class TypeController {
    
    func addRoutes(drop: Droplet) {
        let basic = drop.grouped("types")
        basic.get(Type.self, "projects", handler: projectsIndex)
    }
    
    func index(request: Request) throws -> ResponseRepresentable {
        let types = try Type.all()
        let parameters = try Node(node: [
            "types": types.makeNode(),
            ])
        return try drop.view.make("types", parameters)
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        guard let name = request.data["name"]?.string else {
            return Response(redirect: "/admin/types")
        }
        
        var type = Type(name: name)
        try type.save()
        return Response(redirect: "/admin/types")
    }
    
    func delete(request: Request, type: Type) throws -> ResponseRepresentable {
        try type.delete()
        return Response(redirect: "/admin/types")
    }
    
    func projectsIndex(request: Request, type: Type) throws -> ResponseRepresentable {
        let projects = try type.projects().makeNode(context: ProjectContext.all)
        let parameters = try Node(node: [
            "projects": projects,
            ])
        
        return try drop.view.make("portfolio", parameters)
    }

}

extension Request {
    func type() throws -> Type {
        guard let json = json else {
            throw Abort.badRequest
        }
        return try Type(node: json)
    }
}
