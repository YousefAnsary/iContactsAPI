//
//  ContactController.swift
//  App
//
//  Created by Yousef on 5/3/20.
//

import Vapor
import Fluent
import FluentSQLite
import Dispatch

final class ContactsController {
    
    func boot(router: Router) {
        router.get("contacts/get", use: get)
        router.post("contacts/create", use: save)
        router.patch("contacts/update", use: update)
        router.delete("contacts/delete", use: delete)
    }
    
    func get(_ req: Request) throws -> Future<[ContactData]> {
        let token = try UserController.isAuth(req)
        // Getting all contacts for this user
        return Contact.query(on: req).filter(\.userId == token.userId).all().flatMap { contacts in
            let contactsIds = contacts.map{ $0.id! }
            // Getting all phone numbers& emails that belongs to any contact related to this user
            let phonesQuery = PhoneNumber.query(on: req).filter(\.contactId ~~ contactsIds).all()
            let emailsQuery = Email.query(on: req).filter(\.contactId ~~ contactsIds).all()
            return flatMap(to: [ContactData].self, phonesQuery, emailsQuery) { (fetchedPhones, fetchedEmails) in
                /// Assigning each number& email to its contact and Constructing object for each contact,
                /// appending the array with the new contact
                var contactsData = [ContactData]()
                for contact in contacts {
                    let contactPhones = fetchedPhones.filter { $0.contactId == contact.id! }.map{ $0.phoneNumber }
                    let contactEmails = fetchedEmails.filter { $0.contactId == contact.id! }.map{ $0.email }
                    contactsData.append(ContactData(id: contact.id!, name: contact.name, phoneNumbers: contactPhones, emails: contactEmails))
                }
                return req.eventLoop.newSucceededFuture(result: contactsData)
            }
        }
    }
    
    func save(_ req: Request) throws -> Future<HTTPStatus> {
        let token = try UserController.isAuth(req)
        return try req.content.decode([ContactData].self).map { contacts in
            for contact in contacts {
                try self.save(contact: contact, userId: token.userId, req: req)
            }
            return .created
        }
    }
    
    func save(contact: ContactData, userId: Int, req: Request) throws {
        guard max(contact.phoneNumbers.count, contact.emails.count) > 0 else {throw Abort(HTTPResponseStatus.badRequest)}
        _ = Contact(userId: userId, name: contact.name).save(on: req).map { savedContact in
            for i in 0 ..< max(contact.phoneNumbers.count, contact.emails.count) {
                if i < contact.phoneNumbers.count {
                    _ = PhoneNumber(contactId: savedContact.id!, phoneNumber: contact.phoneNumbers[i]).save(on: req)
                }
                if i < contact.emails.count {
                    _ = Email(contactId: savedContact.id!, email: contact.emails[i]).save(on: req)
                }
            } //End inner loop
        }
    }
    
    func update(_ req: Request) throws -> Future<HTTPStatus> {
        let token = try UserController.isAuth(req)
        return try req.content.decode(ContactData.self).flatMap{ newContact in
            return self.delete(contactWithId: newContact.id!, userId: token.userId, req: req).map{ status in
                guard status == .ok else { throw Abort(HTTPStatus.internalServerError) }
                try self.save(contact: newContact, userId: token.userId, req: req)
            }.transform(to: .ok)
        }
        
    }
    
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        let token = try UserController.isAuth(req)
        
        guard let contactIdString = req.query[String.self, at: "contactId"], let contactId = Int(contactIdString) else {
            throw Abort(HTTPStatus(statusCode: Int(HTTPStatus.badRequest.code), reasonPhrase: "Query parameter `contactId` is missing"))
        }
        // Getting contact with this id
        return delete(contactWithId: contactId, userId: token.userId, req: req)
    }
    
    private func delete(contactWithId id: Int, userId: Int, req: Request)-> Future<HTTPStatus> {
        return Contact.find(id, on: req).map{ contact in
            guard let contact = contact else { throw Abort(HTTPStatus.notFound) }
            guard contact.userId == userId else { throw Abort(HTTPStatus.forbidden) }
            _ = PhoneNumber.query(on: req).filter(\.contactId == contact.id!).all().map{ numbers in
                numbers.forEach{ _ = $0.delete(on: req) }
            }
            _ = Email.query(on: req).filter(\.contactId == contact.id!).all().map{ emails in
                emails.forEach{ _ = $0.delete(on: req) }
            }
            _ = contact.delete(on: req)
            return .ok
        }
    }
    
}
