//
//  CNAddressBookImpl.swift
//  ContactsPicker
//
//  Created by Piotr on 24/11/15.
//  Copyright © 2015 kunai. All rights reserved.
//

import Foundation
import Contacts


internal class CNAddressBookImpl: InternalAddressBook {
    
    private var contactStore: CNContactStore!
    private var saveRequest: CNSaveRequest = CNSaveRequest()
    
    var personCount: Int {
        get {
            do {
                let containerId = contactStore.defaultContainerIdentifier()
                let predicate = CNContact.predicateForContactsInContainerWithIdentifier(containerId)
                return try contactStore.unifiedContactsMatchingPredicate(predicate, keysToFetch: []).count
            } catch let e {
                print("\(e)")
                return 0;
            }
            
        }
    }
    
    internal init() {
        contactStore = CNContactStore()
    }
    
    func requestAccess(completion: (Bool) -> Void) {
        contactStore.requestAccessForEntityType(CNEntityType.Contacts) { (access, err) -> Void in
            completion(access)
        }
    }
    
    func addContact(contact: ContactToInsert) -> AlreadySavedContact {
        let cnContact = CNAdapter.convertKunaiContact(contact)
        saveRequest.addContact(cnContact, toContainerWithIdentifier: nil)
        return CNContactRecord(cnContact: cnContact)
    }
    
    func updateContact(contact: AlreadySavedContact) {
        guard let record = contact as? CNContactRecord else {
            return
        }
        
        saveRequest.updateContact(record.wrappedContact)
    }
    
    func findContactWithIdentifier(identifier: String?) -> AlreadySavedContact? {
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
    
    func deleteContactWithIdentifier(identifier: String?) {
        guard let id = identifier else {
            return
        }
        
        do {
            let contact = try contactStore.unifiedContactWithIdentifier(id, keysToFetch: [CNContactIdentifierKey])
            saveRequest.deleteContact(contact.mutableCopy() as! CNMutableContact)
        } catch {
            // ??
        }
    }
    
    func deleteAllContacts() {
        let containerId = contactStore.defaultContainerIdentifier()
        let predicate = CNContact.predicateForContactsInContainerWithIdentifier(containerId)
        let keys = [CNContactIdentifierKey]
        do {
            let allContacts = try contactStore.unifiedContactsMatchingPredicate(predicate, keysToFetch: keys)
            for var contact in allContacts {
                saveRequest.deleteContact(contact.mutableCopy() as! CNMutableContact)
            }
        } catch let e {
            print(e)
        }
        
    }
    
    func commitChanges() throws {
        try contactStore.executeSaveRequest(saveRequest)
        saveRequest = CNSaveRequest()
    }
}


