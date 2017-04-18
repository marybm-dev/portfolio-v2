import Vapor
import VaporPostgreSQL
import Fluent

final class Media: Model {
    
    var id: Node?
    var exists: Bool = false
    
    var type: String
    var source: String
    var projectId: Node?
    
    init(type: String, source: String, projectId: Node? = nil) {
        self.id = nil
        self.type = type
        self.source = source
        self.projectId = projectId
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        type = try node.extract("type")
        source = try node.extract("source")
        projectId = try node.extract("project_id")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "type": type,
            "source": source,
            "project_id": projectId
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("medias") { media in
            media.id()
            media.string("type")
            media.string("source")
            media.parent(Project.self, optional: false)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("medias")
    }
}
