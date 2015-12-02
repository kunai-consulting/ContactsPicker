//
//  ABContactRecord.swift
//  ContactsPicker
//
//  Created by Piotr on 02/12/15.
//  Copyright © 2015 kunai. All rights reserved.
//

import Foundation
import AddressBook

let abMappings = [
    KunaiLabeledValue.LabelMain : kABPersonPhoneMainLabel as String,
    KunaiLabeledValue.LabelHome : kABPersonHomePageLabel as String,
    KunaiLabeledValue.LabelWork : kABWorkLabel as String,
    KunaiLabeledValue.LabelOther : kABOtherLabel as String,
    KunaiLabeledValue.LabelPhoneiPhone : kABPersonPhoneIPhoneLabel as String,
    KunaiLabeledValue.LabelPhoneMobile : kABPersonPhoneMobileLabel as String
]

internal class ABContactRecord: AlreadySavedContact {
    
    internal let record: ABRecord
    
    internal init(abRecord: ABRecord) {
        record = abRecord
    }
    
    var identifier: String? {
        get {
            return String(ABRecordGetRecordID(record))
        }
    }
    
    var firstName: String? {
        get {
            return ABRecordAdapter.getPropertyFromRecord(record, propertyName: kABPersonFirstNameProperty)
        }
        
        set {
            ABRecordAdapter.setValueToRecord(record, key: kABPersonFirstNameProperty, newValue as NSString?)
        }
    }
    
    var lastName: String? {
        get {
            return ABRecordAdapter.getPropertyFromRecord(record, propertyName: kABPersonLastNameProperty)
        }
        
        set {
            ABRecordAdapter.setValueToRecord(record, key: kABPersonLastNameProperty, newValue as NSString?)
        }
    }
    
    var phoneNumbers: [KunaiLabeledValue]? {
        get {
            return ABRecordAdapter.getMultiValues(record, propertyName:  kABPersonPhoneProperty)
        }
        
        set {
            ABRecordAdapter.setValueToRecord(
                record,
                key: kABPersonPhoneProperty,
                ABRecordAdapter.createMultiValuesFromLabels(record, type: kABPersonPhoneProperty, labels: newValue))
        }
    }
    
    var emailAddresses: [KunaiLabeledValue]? {
        get {
            return ABRecordAdapter.getMultiValues(record, propertyName:  kABPersonEmailProperty)
        }
        
        set {
            ABRecordAdapter.setValueToRecord(
                record,
                key: kABPersonEmailProperty,
                ABRecordAdapter.createMultiValuesFromLabels(record, type: kABPersonEmailProperty, labels: newValue))
        }
    }
    
    var organizationName: String? {
        get {
            return ABRecordAdapter.getPropertyFromRecord(record, propertyName: kABPersonOrganizationProperty)
        }
        
        set {
            ABRecordAdapter.setValueToRecord(record, key: kABPersonOrganizationProperty, newValue as NSString?)
        }
    }
}

internal class ABRecordAdapter {
    
    internal class func toABRecordRef(kunaiContact: ContactToInsert) -> ABRecord {
        let person = ABPersonCreate().takeRetainedValue()
        
        if let phoneNumbers = kunaiContact.phoneNumbers {
            let phoneNumberMultiValue = createMultiValue(kABPersonPhoneProperty)
            
            for var phoneNumberLabeledValue in phoneNumbers {
                ABMultiValueAddValueAndLabel(phoneNumberMultiValue, phoneNumberLabeledValue.value, ContactAdapter.convertLabel(abMappings, label: phoneNumberLabeledValue.label), nil)
            }
            setValueToRecord(person, key: kABPersonPhoneProperty, phoneNumberMultiValue)
        }
        
        if let emailAddresses = kunaiContact.emailAddresses {
            let emailAddressesMultiValue = createMultiValue(kABPersonEmailProperty)
            
            for var emailLabeledValue in emailAddresses {
                ABMultiValueAddValueAndLabel(emailAddressesMultiValue, emailLabeledValue.value, ContactAdapter.convertLabel(abMappings, label: emailLabeledValue.label), nil)
            }
            
            setValueToRecord(person, key: kABPersonEmailProperty, emailAddressesMultiValue)
        }
        
        if let firstName = kunaiContact.firstName {
            setValueToRecord(person, key: kABPersonFirstNameProperty, firstName as NSString)
        }
        
        if let familyName = kunaiContact.lastName {
            setValueToRecord(person, key: kABPersonLastNameProperty, familyName as NSString)
        }
        
        return person
    }
    
    private class func createMultiValuesFromLabels(record: ABRecord, type: ABPropertyID, labels:[KunaiLabeledValue]?) -> ABMutableMultiValue {
        var multiValue = createMultiValue(type)
        let labels = labels ?? [KunaiLabeledValue]()
        for var kunaiValue in labels {
            ABMultiValueAddValueAndLabel(multiValue, kunaiValue.value, ContactAdapter.convertLabel(abMappings, label: kunaiValue.label), nil)
        }
        return multiValue
    }
    
    private class func createMultiValue(type: ABPropertyID) -> ABMutableMultiValue {
        return ABMultiValueCreateMutable(ABPersonGetTypeOfProperty(type)).takeRetainedValue()
    }
    
    private class func setValueToRecord<T : AnyObject>(record : ABRecord!, key : ABPropertyID, _ value : T?) {
        ABRecordSetValue(record, key, value, nil)
    }
    
    
    private class func getPropertyFromRecord<T>(record: ABRecord, propertyName : ABPropertyID) -> T? {
        let value: AnyObject? = ABRecordCopyValue(record, propertyName)?.takeRetainedValue()
        return value as? T
    }
    
    private class func getMultiValues(record: ABRecord, propertyName : ABPropertyID) -> [KunaiLabeledValue] {
        var array = [KunaiLabeledValue]()
        let mappings = abMappings.reversedDictionary
        let multivalue : ABMultiValue? = getPropertyFromRecord(record, propertyName: propertyName)
        for i : Int in 0..<(ABMultiValueGetCount(multivalue)) {
            let value = ABMultiValueCopyValueAtIndex(multivalue, i).takeRetainedValue() as? String
            if let v = value {
                let id : Int = Int(ABMultiValueGetIdentifierAtIndex(multivalue, i))
                let optionalLabel = ABMultiValueCopyLabelAtIndex(multivalue, i)?.takeRetainedValue() as? String
                array.append(
                    KunaiLabeledValue(label: ContactAdapter.convertLabel(mappings, label: optionalLabel), value: v)
                )
            }
        }
        return array
    }
}