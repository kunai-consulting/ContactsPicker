//
//  CNContactRecord.swift
//  ContactsPicker
//
//  Created by Piotr on 02/12/15.
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

internal class CNContactRecord: AlreadySavedContact {
    
    internal let wrappedContact: CNMutableContact
    
    internal convenience init (cnContact: CNContact) {
        self.init(cnContact: cnContact.mutableCopy() as! CNMutableContact)
    }
    
    internal init (cnContact: CNMutableContact) {
        wrappedContact = cnContact
    }
    
    var identifier: String? {
        get {
            return wrappedContact.identifier
        }
    }
    
    var firstName: String? {
        get {
            return wrappedContact.givenName
        }
        set {
            if let value = newValue {
                wrappedContact.givenName = value
            } else {
                wrappedContact.givenName = ""
            }
        }
    }
    
    var lastName: String? {
        get {
            return wrappedContact.familyName
        }
        set {
            if let value = newValue {
                wrappedContact.familyName = value
            } else {
                wrappedContact.familyName = ""
            }
        }
    }
    
    var organizationName: String? {
        get {
            return wrappedContact.organizationName
        }
        set {
            if let value = newValue {
                wrappedContact.organizationName = value
            } else {
                wrappedContact.organizationName = ""
            }
        }
    }
    
    var phoneNumbers: [KunaiLabeledValue]? {
        get {
            return CNAdapter.convertCNLabeledValues(wrappedContact.phoneNumbers)
        }
        set {
            wrappedContact.phoneNumbers = CNAdapter.convertPhoneNumbers(newValue)
        }
    }
    
    var emailAddresses: [KunaiLabeledValue]? {
        get {
            return CNAdapter.convertCNLabeledValues(wrappedContact.emailAddresses)
        }
        set {
            wrappedContact.emailAddresses = CNAdapter.convertEmailAddresses(emailAddresses)
        }
    }
}

internal class CNAdapter {
    
    internal class func convertKunaiContact(kunaiContact: ContactToInsert) -> CNMutableContact {
        let cnContact = CNMutableContact()
        if let firstName = kunaiContact.firstName {
             cnContact.givenName = firstName
        }
        
        if let lastName = kunaiContact.lastName {
            cnContact.familyName = lastName
        }
        
        if let organizationName = kunaiContact.organizationName {
            cnContact.organizationName = organizationName
        }
       
        cnContact.phoneNumbers = convertPhoneNumbers(kunaiContact.phoneNumbers)
        cnContact.emailAddresses = convertEmailAddresses(kunaiContact.emailAddresses)
        
        return cnContact
    }
    
    private class func convertPhoneNumbers(phoneNumbers: [KunaiLabeledValue]?) -> [CNLabeledValue] {
        
        guard let phoneNumbers = phoneNumbers else {
            return [CNLabeledValue]()
        }
        
        return phoneNumbers.map({
            ( kunaiLabeledValue) -> CNLabeledValue in
            
            let label = ContactAdapter.convertLabel(cnMappings, label: kunaiLabeledValue.label)
            var phoneNumber: CNPhoneNumber
            if let phoneNumberAsString = kunaiLabeledValue.value as? String {
                phoneNumber = CNPhoneNumber(stringValue: phoneNumberAsString)
            } else {
                phoneNumber = CNPhoneNumber()
            }
            
            return CNLabeledValue(label: label, value: phoneNumber)
        })
    }
    
    private class func convertEmailAddresses(emailAddresses: [KunaiLabeledValue]?) -> [CNLabeledValue] {
        
        guard let emailAddresses = emailAddresses else {
            return [CNLabeledValue]()
        }
        
        return emailAddresses.map({
            ( kunaiLabeledValue) -> CNLabeledValue in
            
            let label = ContactAdapter.convertLabel(cnMappings, label: kunaiLabeledValue.label)
            let value = kunaiLabeledValue.value
            
            return CNLabeledValue(label: label, value: value)
        })
        
    }
    
    private class func convertCNLabeledValues(cnLabeledValues: [CNLabeledValue]) -> [KunaiLabeledValue] {
        var kunaiLabels = [KunaiLabeledValue]()
        
        let mappings = cnMappings.reversedDictionary
        for cnLabeledValue in cnLabeledValues {
            kunaiLabels.append(
                KunaiLabeledValue(
                    label: ContactAdapter.convertLabel(mappings, label: cnLabeledValue.label),
                    value: cnLabeledValue.value))
        }
        
        return kunaiLabels
    }
}
