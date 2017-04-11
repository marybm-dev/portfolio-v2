import Vapor
import VaporPostgreSQL
import Fluent

final class Tag: Model {

    var id: Node?
    var exists: Bool = false
    var type: String
    var name: String
    
    init(type: String, name: String) {
        self.id = nil
        self.type = type
        self.name = name
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        type = try node.extract("type")
        name = try node.extract("name")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "type": type,
            "name": name
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("tags") { users in
            users.id()
            users.string("type")
            users.string("name")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("tags")
    }
}

extension Tag {
    func projects() throws -> [Project] {
        let projects: Siblings<Project> = try siblings()
        return try projects.all()
    }
}
