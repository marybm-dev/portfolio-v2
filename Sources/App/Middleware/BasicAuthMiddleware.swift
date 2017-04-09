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


/**
 Takes a Basic Authentication header and turns it into a set of API Keys,
 and attempts to authenticate against it.
 */
class BasicAuthMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        var id = ""
        var secret = ""
        
        if let header = request.auth.header {
            let components = header.header.components(separatedBy: ":")
            id = components[0]
            secret = components[1]
        }

        let api_Key = APIKey(id: id, secret: secret)
        try? request.auth.login(api_Key, persist: false)
        
        return try next.respond(to: request)
    }
}
