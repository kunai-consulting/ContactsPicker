//
//  MyAddressBook.swift
//  ContactsPicker
//
//  Created by Piotr on 23/11/15.
//  Copyright © 2015 kunai. All rights reserved.
//

import Foundation

public protocol InternalAddressBook {
    var personCount: Int {
        get
    }
    
    func requestAccess( completion: (Bool) -> Void )
    
    func addContact(contact: KunaiContact)
    
    func deleteAllContacts()
    
    func deleteContactWithIdentifier(identifier: String?)
    
    func findContactWithIdentifier(identifier: String?) -> KunaiContact?
    
    func commitChanges() throws
}

public protocol InternalAddressBookFactory {
    func createInternalAddressBook() -> InternalAddressBook
}

public class APIVersionAddressBookFactory : InternalAddressBookFactory {
    
    public func createInternalAddressBook() -> InternalAddressBook {
        let isOnIOS9OrAbove = NSProcessInfo().isOperatingSystemAtLeastVersion(
            NSOperatingSystemVersion(majorVersion: 9, minorVersion: 0, patchVersion: 0)
        );
        
        if isOnIOS9OrAbove {
            print("iOS >=  9.0.0")
            return CNAddressBookImpl()
        } else {
            print("iOS < 9")
            return ABAddressBookImpl()
        }
    }
}

public class MyAddressBook: InternalAddressBook {
    private var internalAddressBook: InternalAddressBook!
    
    public var personCount : Int {
        get {
            return internalAddressBook.personCount;
        }
    }
    
    public convenience init() {
        self.init(factory: APIVersionAddressBookFactory())
    }
    
    public init(factory: InternalAddressBookFactory) {
        
        internalAddressBook = factory.createInternalAddressBook()
    }
    
    public func requestAccess(completion: (Bool) -> Void) {
        internalAddressBook.requestAccess(completion)
    }
    
    public func addContact(contact: KunaiContact) {
        internalAddressBook.addContact(contact)
    }
    
    public func deleteContactWithIdentifier(identifier: String?) {
        internalAddressBook.deleteContactWithIdentifier(identifier)
    }
    
    public func deleteAllContacts() {
        internalAddressBook.deleteAllContacts()
    }
    
    public func commitChanges() throws {
        try internalAddressBook.commitChanges()
    }
    
    public func findContactWithIdentifier(identifier: String?) -> KunaiContact? {
        return internalAddressBook.findContactWithIdentifier(identifier)
    }
}