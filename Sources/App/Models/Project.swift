import Vapor
import VaporPostgreSQL

final class Project: Model {
    
    var id: Node?
    var exists: Bool = false
    
    var title: String
    var description: String
    var tech: String
    var type: String
    var image: String?
    var video: String?
    var link: String?
    
    init(title: String, description: String, tech: String, type: String, image: String?, video: String?, link: String?) {
        self.id = nil
        self.title = title
        self.description = description
        self.tech = tech
        self.type = type
        self.image = image
        self.video = video
        self.link = link
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        title = try node.extract("title")
        description = try node.extract("description")
        tech = try node.extract("tech")
        type = try node.extract("type")
        image = try node.extract("image")
        video = try node.extract("video")
        link = try node.extract("link")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "title" : title,
            "description": description,
            "tech": tech,
            "type": type,
            "image": image,
            "video": video,
            "link": link
        ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("projects") { users in
            users.id()
            users.string("title")
            users.string("description")
            users.string("tech")
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

enum TechStack: String {
    case iOS, Swift, Android, PostgreSQL, SQLite, MySQL, Vapor, Leaf, Skeleton, Heroku, XCode, RoR, HTML, HAML, CSS, SASS, JavaScript, jQuery, Jasmin, RSpec, Capibara, Bootstrap, AWS, Sketch, Vim
}

enum TechSkills: String {
    case BasicAuthentication, oAuthentication, REST, Persistence, Routes, Templating, HTTPRequests
}
