//
//  Token.swift
//  App
//
//  Created by Yousef on 5/2/20.
//

import Vapor
import FluentSQLite
import JWT

struct Token: SQLiteModel, Migration, Content, Parameter, JWTPayload {
    
    var id: Int?
    var userId: Int
    var token: String
    var tokenCreationDate: Date
    var tokenExpireDate: Date
    
    init(id: Int?, userId: Int, token: String, tokenCreationDate: Date, tokenExpireDate: Date) {
        self.id = id
        self.userId = userId
        self.token = token
        self.tokenCreationDate = tokenCreationDate
        self.tokenExpireDate = tokenExpireDate
    }
    
    func verify(using signer: JWTSigner) throws {}
    
}


