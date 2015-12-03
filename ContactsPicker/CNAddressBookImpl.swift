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
internal class CNAddressBookImpl: InternalAddressBook {
    
    private var contactStore: CNContactStore!
    private var saveRequest: CNSaveRequest = CNSaveRequest()
    
    internal init() {
        contactStore = CNContactStore()
    }
    
    func requestAccessToAddressBook(completion: (Bool, NSError?) -> Void) {
        contactStore.requestAccessForEntityType(CNEntityType.Contacts) { (access, err) -> Void in
            completion(access, err)
        }
    }
    
    func retrieveRecordsCount() throws -> Int {
        let containerId = contactStore.defaultContainerIdentifier()
        let predicate = CNContact.predicateForContactsInContainerWithIdentifier(containerId)
        return try contactStore.unifiedContactsMatchingPredicate(predicate, keysToFetch: []).count
    }
    
    func addContact(contact: ContactValues) throws -> FetchedContactValues {
        let cnContact = CNAdapter.convertContactValuesToCNContact(contact)
        saveRequest.addContact(cnContact, toContainerWithIdentifier: nil)
        return CNContactRecord(cnContact: cnContact)
    }
    
    func updateContact(contact: FetchedContactValues) {
        guard let record = contact as? CNContactRecord else {
            return
        }
        
        saveRequest.updateContact(record.wrappedContact)
    }
    
    func findContactWithIdentifier(identifier: String?) -> FetchedContactValues? {
        guard let id = identifier else {
            return nil
        }

        do {
            let contact = try contactStore.unifiedContactWithIdentifier(id, keysToFetch: [
                    CNContactGivenNameKey,
                    CNContactFamilyNameKey,
                    CNContactEmailAddressesKey,
                    CNContactPhoneNumbersKey,
                    CNContactIdentifierKey
                ])
            
            return CNContactRecord(cnContact: contact.mutableCopy() as! CNMutableContact)
        } catch {
            return nil
        }

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
    
    func commitChanges() throws {
        try contactStore.executeSaveRequest(saveRequest)
        saveRequest = CNSaveRequest()
    }
}


