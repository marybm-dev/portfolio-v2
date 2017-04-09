//
//  BasicAuthMiddleware.swift
//  AuthTemplate
//
//  Created by Anthony Castelli on 10/29/16.
//
//
// Originally from https://github.com/stormpath/Turnstile-Vapor-Example/blob/master/Sources/App/BasicAuthenticationMiddleware.swift
import Vapor
import HTTP
import Turnstile
import Auth
import Sessions


/**
 Takes a Basic Authentication header and turns it into a set of API Keys,
 and attempts to authenticate against it.
 */
class BasicAuthMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        if let id = try request.session().data["api_key"]?.string,
            let secret = try request.session().data["api_secret"]?.string {
            
            let api_Key = APIKey(id: id, secret: secret)
            try? request.auth.login(api_Key, persist: true)
            
        }
//        
//        
//        if let header = request.auth.header {
//            let components = header.header.components(separatedBy: ":")
//            if components.count == 2 {
//                let id = components[0]
//                let secret = components[1]
//                let api_Key = APIKey(id: id, secret: secret)
//                try? request.auth.login(api_Key, persist: true)
//            }
//        }

        return try next.respond(to: request)
    }
}
