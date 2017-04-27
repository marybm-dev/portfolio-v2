import Vapor
import VaporPostgreSQL
import Fluent

final class Project: Model {
    
    var id: Node?
    var exists: Bool = false
    
    var title: String
    var subtitle: String
    var description: String
    var type: String
    var image: String?
    var store: String?
    var link: String?
    
    init(title: String, subtitle: String, description: String, type: String, image: String?, store: String?, link: String?) {
        self.id = nil
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.type = type
        self.image = image
        self.store = store
        self.link = link
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        title = try node.extract("title")
        subtitle = try node.extract("subtitle")
        description = try node.extract("description")
        type = try node.extract("type")
        image = try node.extract("image")
        store = try node.extract("store")
        link = try node.extract("link")
    }
    
    func makeNode(context: Context) throws -> Node {
        
        var node: [String: Node]  = [:]
        node["id"] = id
        node["title"] = title.makeNode()
        node["subtitle"] = subtitle.makeNode()
        node["description"] = description.makeNode()
        node["type"] = type.makeNode()
        
        if let image = image {
            node["image"] = image.makeNode()
        }
        if let link = link {
            node["link"] = link.makeNode()
        }
        if let store = store {
            node["store"] = store.makeNode()
        }
        
        switch context {
        case ProjectContext.all:
            let allTags = try tags()
            if allTags.count > 0 {
                node["tags"] = try allTags.makeNode()
            }
            
            let allMedias = try medias()
            if allMedias.count > 0 {
                node["medias"] = try allMedias.makeNode()
            }
            
        default:
            break
        }
        
        return try node.makeNode()
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("projects") { projects in
            projects.id()
            projects.string("title")
            projects.string("subtitle")
            projects.custom("description", type: "TEXT")
            projects.string("type")
            projects.string("image", optional: true)
            projects.string("link", optional: true)
            projects.string("store", optional: true)
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
    
    func medias() throws -> [Media] {
        return try children(nil, Media.self).all()
    }
}

public enum ProjectContext: Context {
    case all
}
