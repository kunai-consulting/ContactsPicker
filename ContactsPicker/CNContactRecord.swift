//
//  CNContactRecord.swift
//  ContactsPicker
//
//  Created by Piotr on 02/12/15.
//  Copyright © 2015 kunai. All rights reserved.
//

import Foundation
import Contacts

@available(iOS 9.0, *)
let cnMappings = [
    LabeledValue.LabelMain : CNLabelPhoneNumberMain,
    LabeledValue.LabelHome : CNLabelHome,
    LabeledValue.LabelWork : CNLabelWork,
    LabeledValue.LabelOther : CNLabelOther,
    LabeledValue.LabelPhoneiPhone : CNLabelPhoneNumberiPhone,
    LabeledValue.LabelPhoneMobile : CNLabelPhoneNumberMobile
]

@available(iOS 9.0, *)
internal class CNContactRecord: FetchedContactValues {
    
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
    
    var phoneNumbers: [LabeledValue]? {
        get {
            return CNAdapter.convertCNLabeledValues(wrappedContact.phoneNumbers)
        }
        set {
            wrappedContact.phoneNumbers = CNAdapter.convertPhoneNumbers(newValue)
        }
    }
    
    var emailAddresses: [LabeledValue]? {
        get {
            return CNAdapter.convertCNLabeledValues(wrappedContact.emailAddresses)
        }
        set {
            wrappedContact.emailAddresses = CNAdapter.convertEmailAddresses(emailAddresses)
        }
    }
}

@available(iOS 9.0, *)
internal class CNAdapter {
    
    internal class func convertKunaiContact(kunaiContact: ContactValues) -> CNMutableContact {
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
    
    private class func convertPhoneNumbers(phoneNumbers: [LabeledValue]?) -> [CNLabeledValue] {
        
        guard let phoneNumbers = phoneNumbers else {
            return [CNLabeledValue]()
        }
        
        return phoneNumbers.map({
            ( LabeledValue) -> CNLabeledValue in
            
            let label = ContactAdapter.convertLabel(cnMappings, label: LabeledValue.label)
            var phoneNumber: CNPhoneNumber
            if let phoneNumberAsString = LabeledValue.value as? String {
                phoneNumber = CNPhoneNumber(stringValue: phoneNumberAsString)
            } else {
                phoneNumber = CNPhoneNumber()
            }
            
            return CNLabeledValue(label: label, value: phoneNumber)
        })
    }
    
    private class func convertEmailAddresses(emailAddresses: [LabeledValue]?) -> [CNLabeledValue] {
        
        guard let emailAddresses = emailAddresses else {
            return [CNLabeledValue]()
        }
        
        return emailAddresses.map({
            ( LabeledValue) -> CNLabeledValue in
            
            let label = ContactAdapter.convertLabel(cnMappings, label: LabeledValue.label)
            let value = LabeledValue.value
            
            return CNLabeledValue(label: label, value: value)
        })
        
    }
    
    private class func convertCNLabeledValues(cnLabeledValues: [CNLabeledValue]) -> [LabeledValue] {
        var kunaiLabels = [LabeledValue]()
        
        let mappings = DictionaryUtils.dictionaryWithSwappedKeysAndValues(cnMappings)
        for cnLabeledValue in cnLabeledValues {
            kunaiLabels.append(
                LabeledValue(
                    label: ContactAdapter.convertLabel(mappings, label: cnLabeledValue.label),
                    value: cnLabeledValue.value))
        }
        
        return kunaiLabels
    }
}
