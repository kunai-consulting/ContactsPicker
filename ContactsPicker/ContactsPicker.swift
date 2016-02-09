//
//  MyAddressBook.swift
//  ContactsPicker
//
//  Created by Piotr on 23/11/15.
//  Copyright © 2015 kunai. All rights reserved.
//

import Foundation

public protocol AddressBookProtocol {
    
    func requestAccessToAddressBook( completion: (Bool, NSError?) -> Void )

    func retrieveAddressBookRecordsCount() throws -> Int

    func addContactToAddressBook(contact: ContactProtocol) throws -> ContactProtocol
    
    func updateContact(contact: ContactProtocol)
    
    func deleteAllContacts() throws
    
    func deleteContactWithIdentifier(identifier: String?) throws
    
    func queryBuilder() -> AddressBookQueryBuilder
    
    func findContactWithIdentifier(identifier: String?) -> ContactProtocol?
    
    func findContactsMatchingName(name: String) throws -> [ContactProtocol]
    
    func findAllContacts() throws -> [ContactProtocol]

    func commitChangesToAddressBook() throws
}

public protocol AddressBookFactory {
    func createAddressBook() throws -> AddressBookProtocol
}

public class APIVersionAddressBookFactory : AddressBookFactory {
    
    public func createAddressBook() throws -> AddressBookProtocol {

        if #available(iOS 9.0, *) {
            return CNAddressBookImpl()
        } else {
           return try ABAddressBookImpl()
        }
        
    }
}

public class AddressBook: AddressBookProtocol {
    private var internalAddressBook: AddressBookProtocol!
    
    public convenience init() throws {
        try self.init(factory: APIVersionAddressBookFactory())
    }
    
    public init(factory: AddressBookFactory) throws {
        internalAddressBook = try factory.createAddressBook()
    }
    
    public func requestAccessToAddressBook(completion: (Bool, NSError?) -> Void) {
        internalAddressBook.requestAccessToAddressBook(completion)
    }
    
    public func retrieveAddressBookRecordsCount() throws -> Int {
        return try internalAddressBook.retrieveAddressBookRecordsCount()
    }
    
    public func addContactToAddressBook(contact: ContactProtocol) throws -> ContactProtocol {
        return try internalAddressBook.addContactToAddressBook(contact)
    }
    
    public func updateContact(contact: ContactProtocol) {
        internalAddressBook.updateContact(contact)
    }
    
    public func deleteContactWithIdentifier(identifier: String?) throws {
        try internalAddressBook.deleteContactWithIdentifier(identifier)
    }
    
    public func deleteAllContacts() throws {
        try internalAddressBook.deleteAllContacts()
    }
    
    public func commitChangesToAddressBook() throws {
        try internalAddressBook.commitChangesToAddressBook()
    }
    
    public func queryBuilder() -> AddressBookQueryBuilder {
        return internalAddressBook.queryBuilder()
    }
    
    public func findContactWithIdentifier(identifier: String?) -> ContactProtocol? {
        return internalAddressBook.findContactWithIdentifier(identifier)
    }
    
    public func findAllContacts() throws -> [ContactProtocol] {
        return try internalAddressBook.findAllContacts()
    }
    
    public func findContactsMatchingName(name: String) throws -> [ContactProtocol] {
        return try internalAddressBook.findContactsMatchingName(name)
    }
}