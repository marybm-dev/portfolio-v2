import Vapor
import HTTP

final class TypeController {
    
    func addRoutes(drop: Droplet) {
        let basic = drop.grouped("types")
        basic.get(handler: index)
        basic.post(handler: create)
        basic.delete(Type.self, handler: delete)
        basic.get(Type.self, "projects", handler: projectsIndex)
    }
    
    func index(request: Request) throws -> ResponseRepresentable {
        return try JSON(node: Type.all().makeNode())
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        guard let name = request.data["name"]?.string else {
                throw Abort.badRequest
        }
        
        var type = Type(name: name)
        try type.save()
        return type
    }
    
    func delete(request: Request, type: Type) throws -> ResponseRepresentable {
        try type.delete()
        return JSON([:])
    }
    
    func projectsIndex(request: Request, type: Type) throws -> ResponseRepresentable {
        let projects = try type.projects().makeNode(context: ProjectContext.all)
        let parameters = try Node(node: [
            "projects": projects,
            ])
        
        return try drop.view.make("portfolio", parameters)
    }
    
//    func projectsIndex(request: Request, type: Type) throws -> ResponseRepresentable {
//        let projects = try type.projects()
//        return try JSON(node: projects.makeNode())
//    }
//    

}

extension Request {
    func type() throws -> Type {
        guard let json = json else {
            throw Abort.badRequest
        }
        return try Type(node: json)
    }
}
