//
//  CNAddressBookImpl.swift
//  ContactsPicker
//
//  Created by Piotr on 24/11/15.
//  Copyright © 2015 kunai. All rights reserved.
//

import Foundation
import Contacts

@available(iOS 9.0, *)
internal class CNAddressBookImpl: AddressBookProtocol {
    
    private var contactStore: CNContactStore!
    private var saveRequest: CNSaveRequest = CNSaveRequest()
    private let defaultKeysToFetch = [
        CNContactGivenNameKey,
        CNContactMiddleNameKey,
        CNContactFamilyNameKey,
        CNContactEmailAddressesKey,
        CNContactPhoneNumbersKey,
        CNContactIdentifierKey
    ]
    
    internal var allContactsPredicate: NSPredicate {
        get {
            let containerId = contactStore.defaultContainerIdentifier()
            let predicate = CNContact.predicateForContactsInContainerWithIdentifier(containerId)
            return predicate
        }
    }
    
    internal init() {
        contactStore = CNContactStore()
    }
    
    func requestAccessToAddressBook(completion: (Bool, NSError?) -> Void) {
        contactStore.requestAccessForEntityType(CNEntityType.Contacts) { (access, err) -> Void in
            completion(access, err)
        }
    }
    
    func retrieveAddressBookRecordsCount() throws -> Int {
        let containerId = contactStore.defaultContainerIdentifier()
        let predicate = CNContact.predicateForContactsInContainerWithIdentifier(containerId)
        return try contactStore.unifiedContactsMatchingPredicate(predicate, keysToFetch: []).count
    }
    
    func addContactToAddressBook(contact: ContactProtocol) throws -> ContactProtocol {
        let cnContact = CNAdapter.convertContactValuesToCNContact(contact)
        saveRequest.addContact(cnContact, toContainerWithIdentifier: nil)
        return CNContactRecord(cnContact: cnContact)
    }
    
    func updateContact(contact: ContactProtocol) {
        guard let record = contact as? CNContactRecord else {
            return
        }
        
        saveRequest.updateContact(record.wrappedContact)
    }
    
    func findContactWithIdentifier(identifier: String?) -> ContactProtocol? {
        guard let id = identifier else {
            return nil
        }

        do {
            let contact = try contactStore.unifiedContactWithIdentifier(id, keysToFetch: defaultKeysToFetch)
            return CNContactRecord(cnContact: contact.mutableCopy() as! CNMutableContact)
        } catch {
            return nil
        }
    }
    
    func queryBuilder() -> AddressBookQueryBuilder {
        return CNAddressBookQueryBuilder(addressBook: self)
    }
    
    func findAllContacts() throws -> [ContactProtocol] {
        return try fetchContactsUsingPredicate(allContactsPredicate)
    }
    
    func findContactsMatchingName(name: String) throws -> [ContactProtocol] {
        let predicate = CNContact.predicateForContactsMatchingName(name)
        return try fetchContactsUsingPredicate(predicate)
    }
    
    func fetchContactsUsingPredicate(predicate: NSPredicate) throws -> [ContactProtocol] {
        return try fetchContactsUsingPredicate(predicate, keys: defaultKeysToFetch)
    }
    
    func fetchContactsUsingPredicate(predicate: NSPredicate, keys: [String]) throws -> [ContactProtocol] {
        let cnContacts = try contactStore.unifiedContactsMatchingPredicate(predicate, keysToFetch: keys)
        return CNAdapter.convertCNContactsToContactRecords(cnContacts)
    }
    
    func deleteContactWithIdentifier(identifier: String?) throws {
        guard let id = identifier else {
            return
        }

        do {
            let contact = try contactStore.unifiedContactWithIdentifier(id, keysToFetch: [CNContactIdentifierKey])
            saveRequest.deleteContact(contact.mutableCopy() as! CNMutableContact)
        } catch let e{
            throw e
        }
    }
    
    func deleteAllContacts() throws {
        let containerId = contactStore.defaultContainerIdentifier()
        let predicate = CNContact.predicateForContactsInContainerWithIdentifier(containerId)
        let keys = [CNContactIdentifierKey]
        do {
            let allContacts = try contactStore.unifiedContactsMatchingPredicate(predicate, keysToFetch: keys)
            for var contact in allContacts {
                saveRequest.deleteContact(contact.mutableCopy() as! CNMutableContact)
            }
        } catch let e {
            throw e
        }
        
    }
    
    func commitChangesToAddressBook() throws {
        try contactStore.executeSaveRequest(saveRequest)
        saveRequest = CNSaveRequest()
    }
}


