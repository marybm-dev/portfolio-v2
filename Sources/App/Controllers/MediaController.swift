import Vapor
import HTTP

final class MediaController {

    func addRoutes(drop: Droplet) {
        drop.post("medias", "project", Project.self, handler: create)
    }
        
    func index(request: Request) throws -> ResponseRepresentable {
        let medias = try Media.all()
        let parameters = try Node(node: [
            "medias": medias.makeNode(),
            ])
        return try drop.view.make("/private/medias", parameters)
    }
    
    func create(request: Request, project: Project) throws -> ResponseRepresentable {
        guard let projectId = project.id,
            let type = request.data["type"]?.string,
            let source = request.data["source"]?.string else {
            throw Abort.badRequest
        }

        var media = Media(type: type, source: source, projectId: projectId)
        try media.save()
        return Response(redirect: "/admin/projects")
    }
    
    func delete(request: Request, media: Media) throws -> ResponseRepresentable {
        try media.delete()
        return Response(redirect: "/admin/medias")
    }

}

extension Request {
    func media() throws -> Media {
        guard let json = json else {
            throw Abort.badRequest
        }
        return try Media(node: json)
    }
}
