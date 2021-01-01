//
//  User.swift
//  App
//
//  Created by Yousef on 5/2/20.
//

import Vapor
import FluentSQLite
import JWT
import Crypto

struct User: SQLiteModel, Migration, Content, Parameter {
    
    var id: Int?
    var name: String
    var email: String
    var hashedPassword: String
    
    init(registerData: RegisterData) {
        name = registerData.name
        email = registerData.email
        hashedPassword = (try? BCrypt.hash(registerData.password)) ?? registerData.password
    }
    
    /// Checks for previous existance of this email before creating a new user
    func willCreate(on conn: SQLiteConnection) throws -> EventLoopFuture<User> {
        return User.query(on: conn).filter(\User.email == email).first().map { user in
            if user == nil {
                return self
            } else {
                throw Abort(HTTPResponseStatus.custom(code: 400, reasonPhrase: "Used E-Mail"))
            }
        }
    }
    
}

/// Data needed in login post request
struct LoginData: Content {
    var email, password: String
}

/// Data needed in register post request
struct RegisterData: Content {
    var name: String
    var email: String
    var password: String
    var confirmPassword: String
}

/// Model for response
struct UserData: Content {
    
    var name: String
    var email: String
    var token: String
    var tokenCreationDate: Date
    var tokenExpireDate: Date
    
    init(name: String, email: String, token: Token) {
        self.name = name
        self.email = email
        self.token = token.token
        self.tokenCreationDate = token.tokenCreationDate
        self.tokenExpireDate = token.tokenExpireDate
    }
    
    
}

