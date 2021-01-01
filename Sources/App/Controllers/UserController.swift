//
//  UserController.swift
//  App
//
//  Created by Yousef on 5/2/20.
//

import Crypto
import Vapor
import FluentSQLite
import JWT

/// Creates new users and logs them in.
final class UserController {
    
    func boot(router: Router) {
        router.post("register", use: register)
        router.post("login", use: login)
    }
    
    static func isAuth(_ req: Request) throws -> Token {
        guard let bearer = req.http.headers.bearerAuthorization else {
            throw Abort(.unauthorized)
        }
        
        // parse JWT from token string, using HS-256 signer
        do {
            let token = try JWT<Token>(from: bearer.token, verifiedUsing: .hs256(key: "secret")).payload
            guard token.tokenExpireDate > Date() else { throw Abort(.unauthorized) }
            return token
        }
        catch {throw Abort(.unauthorized)}
    }
    
    func register(_ req: Request) throws -> Future<UserData> {
        return try req.content.decode(RegisterData.self).flatMap { data in
            /// Ensure password equals confirm password
            guard data.password == data.confirmPassword else {
                throw Abort(HTTPResponseStatus.custom(code: 400, reasonPhrase: "Passwords Mismatch"))
            }
            /// Ensure email is valid
            do { try Validator.email.validate(data.email) } catch {
                throw Abort(HTTPResponseStatus.custom(code: 400, reasonPhrase: "Invalid E-Mail"))
            }
            /// Email prev existance is checked in model before saving then generate token for him, return his data
            return User(registerData: data).save(on: req).map { user in
                var token = Token(id: nil, userId: user.id!, token: "", tokenCreationDate: Date(),
                                  tokenExpireDate: Date().addingTimeInterval(7*24*60*60))
                let tokenData = try JWT<Token>(payload: token).sign(using: .hs256(key: "secret"))
                let tokenString = String(data: tokenData, encoding: .utf8) ?? ""
                token.token = tokenString
                _ = token.save(on: req)
                return UserData(name: user.name, email: user.email, token: token)
            }
        }
    }
    
    func login(_ req: Request) throws -> Future<UserData> {
        return try req.content.decode(LoginData.self).flatMap { data in
            User.query(on: req).filter(\User.email == data.email).first().map { user in
                /// Email is unique, if exists then check for password
                guard let user = user, try BCrypt.verify(data.password, created: user.hashedPassword) else {
                    throw Abort(HTTPResponseStatus.unauthorized)
                }
                var token = Token(id: nil, userId: user.id!, token: "", tokenCreationDate: Date(),
                                  tokenExpireDate: Date().addingTimeInterval(7*24*60*60))
                let tokenData = try JWT<Token>(payload: token).sign(using: .hs256(key: "secret"))
                let tokenString = String(data: tokenData, encoding: .utf8) ?? ""
                token.token = tokenString
                _ = token.save(on: req)
                return UserData(name: user.name, email: user.email, token: token)
            }
        }
    }
    
}
