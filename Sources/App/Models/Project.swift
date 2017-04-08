import Vapor
import VaporPostgreSQL


final class Project: Model {
    
    var id: Node?
    var exists: Bool = false
    
    var title: String
    var description: String
    var techStack: String
    var imagePath: String?
    var videoPath: String?
    var link: String?
    
    init(title: String, description: String, techStack: String, imagePath: String?, videoPath: String?, link: String?) {
        self.id = nil
        self.title = title
        self.description = description
        self.techStack = techStack
        self.imagePath = imagePath
        self.videoPath = videoPath
        self.link = link
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        title = try node.extract("title")
        description = try node.extract("description")
        techStack = try node.extract("techStack")
        imagePath = try node.extract("imagePath")
        videoPath = try node.extract("videoPath")
        link = try node.extract("link")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "title" : title,
            "description": description,
            "techStack": techStack,
            "imagePath": imagePath,
            "videoPath": videoPath,
            "link": link
        ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("projects") { users in
            users.id()
            users.string("title")
            users.string("description")
            users.string("techStack")
            users.string("imagePath")
            users.string("videoPath")
            users.string("link")
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
