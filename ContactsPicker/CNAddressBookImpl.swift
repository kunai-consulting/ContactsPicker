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
        
        let request = CNSaveRequest()
        request.addContact(cnContact, toContainerWithIdentifier: nil)
        
        do {
           try contactStore.executeSaveRequest(request)
        }
        catch let e{
            print(e)
        }
    }
}

private class CNAdapter : KunaiContactAdapter<CNMutableContact>{
    
    override var mappings: [String:String] {
        get {
            return [
                KunaiLabeledValue.LabelMain : CNLabelPhoneNumberMain,
                KunaiLabeledValue.LabelHome : CNLabelHome,
                KunaiLabeledValue.LabelWork : CNLabelWork,
                KunaiLabeledValue.LabelOther : CNLabelOther,
                KunaiLabeledValue.LabelPhoneiPhone : CNLabelPhoneNumberiPhone,
                KunaiLabeledValue.LabelPhoneMobile : CNLabelPhoneNumberMobile
            ]
        }
    }
    
    override var convertedObject: CNMutableContact? {
        get {
            return toCNContact()
        }
    }
    
    internal override init(kunaiContact: KunaiContact) {
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

