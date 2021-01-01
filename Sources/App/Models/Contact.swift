//
//  Contact.swift
//  App
//
//  Created by Yousef on 5/2/20.
//

import Vapor
import FluentSQLite

struct Contact: SQLiteModel, Migration, Content, Parameter {
    
    var id: Int?
    var userId: Int
    var name: String
    
    init(userId: Int, name: String) {
        self.userId = userId
        self.name = name
    }
    
}

struct PhoneNumber: SQLiteModel, Migration, Content, Parameter {
    
    var id: Int?
    var contactId: Int
    var phoneNumber: String
    
    init(contactId: Int, phoneNumber: String) {
        self.contactId = contactId
        self.phoneNumber = phoneNumber
    }
    
}

struct Email: SQLiteModel, Migration, Content, Parameter {
    
    var id: Int?
    var contactId: Int
    var email: String
    
    init(contactId: Int, email: String) {
        self.contactId = contactId
        self.email = email
    }
    
}

/// Model For Response
struct ContactData: Content {
    
    var id: Int?
    var name: String
    var phoneNumbers: [String]
    var emails: [String]
    
    init(id: Int?, name: String, phoneNumbers: [String], emails: [String]) {
        self.id = id
        self.name = name
        self.phoneNumbers = phoneNumbers
        self.emails = emails
    }
    
}
