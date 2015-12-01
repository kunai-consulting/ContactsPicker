//
//  CNAddressBookImpl.swift
//  ContactsPicker
//
//  Created by Piotr on 24/11/15.
//  Copyright © 2015 kunai. All rights reserved.
//

import Foundation
import Contacts

let cnMappings = [
    KunaiLabeledValue.LabelMain : CNLabelPhoneNumberMain,
    KunaiLabeledValue.LabelHome : CNLabelHome,
    KunaiLabeledValue.LabelWork : CNLabelWork,
    KunaiLabeledValue.LabelOther : CNLabelOther,
    KunaiLabeledValue.LabelPhoneiPhone : CNLabelPhoneNumberiPhone,
    KunaiLabeledValue.LabelPhoneMobile : CNLabelPhoneNumberMobile
]

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
    
    func addContact(contact: KunaiContact) {
        let adapter = CNAdapter(kunaiContact:contact)
        let cnContact = adapter.toCNContact()
        saveRequest.addContact(cnContact, toContainerWithIdentifier: nil)
        contact.identifier = cnContact.identifier
    }
    
    func findContactWithIdentifier(identifier: String?) -> KunaiContact? {
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
            let adapter = CNKunaiContactAdapter(internalContact: contact)
            return adapter.convertedToKunaiContact
            
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

private class CNKunaiContactAdapter : InternalContactAdapter<CNContact> {
    
    override var mappings: [String:String] {
        get {
            return cnMappings.reversedDictionary
        }
    }
    
    override var convertedToKunaiContact: KunaiContact? {
        get {
            return toKunaiContact()
        }
    }
    
    private override init(internalContact: CNContact) {
        super.init(internalContact: internalContact)
    }
    
    private func toKunaiContact() -> KunaiContact {
        let cnContact = internalContact
        let kunaiContact = KunaiContact()
        kunaiContact.firstName = cnContact.givenName
        kunaiContact.lastName = cnContact.familyName
        kunaiContact.phoneNumbers = convertCNLabeledValues(cnContact.phoneNumbers)
        kunaiContact.emailAddresses = convertCNLabeledValues(cnContact.emailAddresses)
        
        kunaiContact.identifier = cnContact.identifier
        return kunaiContact
    }
    
    private func convertCNLabeledValues(cnLabeledValues: [CNLabeledValue]) -> [KunaiLabeledValue] {
        var kunaiLabels = [KunaiLabeledValue]()
        
        for cnLabeledValue in cnLabeledValues {
            kunaiLabels.append(
                KunaiLabeledValue(
                    label: convertLabel(cnLabeledValue.label),
                    value: cnLabeledValue.value))
        }
        
        return kunaiLabels
    }
}

private class CNAdapter : KunaiContactAdapter<CNMutableContact>{
    
    override var mappings: [String:String] {
        get {
            return cnMappings
        }
    }
    
    override var convertedObject: CNMutableContact? {
        get {
            return toCNContact()
        }
    }
    
    private override init(kunaiContact: KunaiContact) {
        super.init(kunaiContact: kunaiContact)
    }
    
    private func toCNContact() -> CNMutableContact {
        let contact = CNMutableContact()
        if let phoneNumers = convertPhoneNumbers() {
            contact.phoneNumbers = phoneNumers
        }
        
        if let emailAddresses = convertEmailAddresses() {
            contact.emailAddresses = emailAddresses
        }
        
        if let firstName = kunaiContact.firstName {
            contact.givenName = firstName
        }
        
        if let familyName = kunaiContact.lastName {
            contact.familyName = familyName
        }
        return contact 
    }
    
    private func convertPhoneNumbers() -> [CNLabeledValue]? {
        guard let phoneNumbers = kunaiContact.phoneNumbers else {
            return nil
        }
        
        return phoneNumbers.map({
            ( kunaiLabeledValue) -> CNLabeledValue in
            
            let label = convertLabel(kunaiLabeledValue.label)
            var phoneNumber: CNPhoneNumber
            if let phoneNumberAsString = kunaiLabeledValue.value as? String {
                phoneNumber = CNPhoneNumber(stringValue: phoneNumberAsString)
            } else {
                phoneNumber = CNPhoneNumber()
            }
            
            return CNLabeledValue(label: label, value: phoneNumber)
        })
    }
    
    private func convertEmailAddresses() -> [CNLabeledValue]? {
        guard let emails = kunaiContact.emailAddresses else {
            return nil
        }
        
        return emails.map({
            ( kunaiLabeledValue) -> CNLabeledValue in
            
            let label = convertLabel(kunaiLabeledValue.label)
            let value = kunaiLabeledValue.value
            
            return CNLabeledValue(label: label, value: value)
        })
        
    }
}

