import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {

    let userController = UserController()
    userController.boot(router: router)
    
    let contactsController = ContactsController()
    contactsController.boot(router: router)
    
}
