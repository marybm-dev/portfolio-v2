import Vapor
import VaporPostgreSQL
import Fluent

final class Project: Model {
    
    var id: Node?
    var exists: Bool = false
    
    var title: String
    var description: String
    var type: String
    var image: String?
    var video: String?
    var link: String?
    
    init(title: String, description: String, type: String, image: String?, video: String?, link: String?) {
        self.id = nil
        self.title = title
        self.description = description
        self.type = type
        self.image = image
        self.video = video
        self.link = link
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        title = try node.extract("title")
        description = try node.extract("description")
        type = try node.extract("type")
        image = try node.extract("image")
        video = try node.extract("video")
        link = try node.extract("link")
    }
    
    func makeNode(context: Context) throws -> Node {
        
        var node: [String: Node]  = [:]
        node["id"] = id
        node["title"] = title.makeNode()
        node["description"] = description.makeNode()
        node["type"] = type.makeNode()
        node["image"] = image?.makeNode()
        node["video"] = video?.makeNode()
        node["link"] = link?.makeNode()
        
        switch context {
        case ProjectContext.all:
            let allTags = try tags()
            if allTags.count > 0 {
                node["tags"] = try allTags.makeNode()
            }
            
        default:
            break
        }
        
        return try node.makeNode()
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("projects") { users in
            users.id()
            users.string("title")
            users.string("description")
            users.string("type")
            users.string("image", optional: true)
            users.string("video", optional: true)
            users.string("link", optional: true)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("projects")
    }
}

extension Project {
    func tags() throws -> [Tag] {
        let tags: Siblings<Tag> = try siblings()
        return try tags.all()
    }
    
    
    // TODO come back to this
    func getProjectWithTags() throws -> Node {
        return try Node(node: [
            "id" : self.id,
            "tags" : self.tags().makeNode()
        ])
    }
}

public enum ProjectContext: Context {
    case all
}

enum TechStack: String {
    case iOS, Swift, Android, PostgreSQL, SQLite, MySQL, Vapor, Leaf, Skeleton, Heroku, XCode, RoR, HTML, HAML, CSS, SASS, JavaScript, jQuery, Jasmin, RSpec, Capibara, Bootstrap, AWS, Sketch, Vim
}

enum TechSkills: String {
    case BasicAuthentication, oAuthentication, REST, Persistence, Routes, Templating, HTTPRequests
}
