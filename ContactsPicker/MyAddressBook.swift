//
//  MyAddressBook.swift
//  ContactsPicker
//
//  Created by Piotr on 23/11/15.
//  Copyright © 2015 kunai. All rights reserved.
//

import Foundation

public protocol InternalAddressBook {
    
    func requestAccessToAddressBook( completion: (Bool, NSError?) -> Void )
    
    func retrieveRecordsCount() throws -> Int
    
    func addContact(contact: ContactValues) throws -> FetchedContactValues
    
    func updateContact(contact: FetchedContactValues)
    
    func deleteAllContacts() throws
    
    func deleteContactWithIdentifier(identifier: String?) throws
    
    func findContactWithIdentifier(identifier: String?) -> FetchedContactValues?
    
    func commitChanges() throws
}

public protocol InternalAddressBookFactory {
    func createInternalAddressBook() throws -> InternalAddressBook
}

public class APIVersionAddressBookFactory : InternalAddressBookFactory {
    
    public func createInternalAddressBook() throws -> InternalAddressBook {

        if #available(iOS 9.0, *) {
        return CNAddressBookImpl()
        } else {
           return try ABAddressBookImpl()
        }
        
    }
}

public class MyAddressBook: InternalAddressBook {
    private var internalAddressBook: InternalAddressBook!
    
    public convenience init() throws {
        try self.init(factory: APIVersionAddressBookFactory())
    }
    
    public init(factory: InternalAddressBookFactory) throws {
        internalAddressBook = try factory.createInternalAddressBook()
    }
    
    public func requestAccessToAddressBook(completion: (Bool, NSError?) -> Void) {
        internalAddressBook.requestAccessToAddressBook(completion)
    }
    
    public func retrieveRecordsCount() throws -> Int {
        return try internalAddressBook.retrieveRecordsCount()
    }
    
    public func addContact(contact: ContactValues) throws -> FetchedContactValues {
        return try internalAddressBook.addContact(contact)
    }
    
    public func updateContact(contact: FetchedContactValues) {
        internalAddressBook.updateContact(contact)
    }
    
    public func deleteContactWithIdentifier(identifier: String?) throws {
        try internalAddressBook.deleteContactWithIdentifier(identifier)
    }
    
    public func deleteAllContacts() throws {
        try internalAddressBook.deleteAllContacts()
    }
    
    public func commitChanges() throws {
        try internalAddressBook.commitChanges()
    }
    
    public func findContactWithIdentifier(identifier: String?) -> FetchedContactValues? {
        return internalAddressBook.findContactWithIdentifier(identifier)
    }
}