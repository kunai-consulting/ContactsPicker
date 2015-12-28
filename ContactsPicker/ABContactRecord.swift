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
    AddressBookRecordLabel.LabelType.Main.rawValue : kABPersonPhoneMainLabel as String,
    AddressBookRecordLabel.LabelType.Home.rawValue : kABPersonHomePageLabel as String,
    AddressBookRecordLabel.LabelType.Work.rawValue : kABWorkLabel as String,
    AddressBookRecordLabel.LabelType.Other.rawValue : kABOtherLabel as String,
    AddressBookRecordLabel.LabelType.PhoneiPhone.rawValue : kABPersonPhoneIPhoneLabel as String,
    AddressBookRecordLabel.LabelType.PhoneMobile.rawValue : kABPersonPhoneMobileLabel as String
]

internal class ABContactRecord: ContactProtocol {
    
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
    
    var middleName: String? {
        get {
            return ABRecordAdapter.getPropertyFromRecord(record, propertyName: kABPersonMiddleNameProperty)
        }
        
        set {
            ABRecordAdapter.setValueToRecord(record, key: kABPersonMiddleNameProperty, newValue as NSString?)
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
    
    var phoneNumbers: [AddressBookRecordLabel]? {
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
    
    var emailAddresses: [AddressBookRecordLabel]? {
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
    
    internal class func convertABRecordsToContactValues(abRecords: [ABRecord]) -> [ContactProtocol] {
        return abRecords.map({ (record) -> ContactProtocol in
            return ABContactRecord(abRecord: record)
        })
    }
    
    internal class func convertContactToABRecord(contact: ContactProtocol) -> ABRecord {
        let person = ABPersonCreate().takeRetainedValue()
        
        if let phoneNumbers = contact.phoneNumbers {
            let phoneNumberMultiValue = createMultiValue(kABPersonPhoneProperty)
            
            for var phoneNumberLabeledValue in phoneNumbers {
                ABMultiValueAddValueAndLabel(phoneNumberMultiValue, phoneNumberLabeledValue.value, AddressBookRecordLabel.convertLabel(abMappings, label: phoneNumberLabeledValue.label), nil)
            }
            setValueToRecord(person, key: kABPersonPhoneProperty, phoneNumberMultiValue)
        }
        
        if let emailAddresses = contact.emailAddresses {
            let emailAddressesMultiValue = createMultiValue(kABPersonEmailProperty)
            
            for var emailLabeledValue in emailAddresses {
                ABMultiValueAddValueAndLabel(emailAddressesMultiValue, emailLabeledValue.value, AddressBookRecordLabel.convertLabel(abMappings, label: emailLabeledValue.label), nil)
            }
            
            setValueToRecord(person, key: kABPersonEmailProperty, emailAddressesMultiValue)
        }
        
        if let firstName = contact.firstName {
            setValueToRecord(person, key: kABPersonFirstNameProperty, firstName as NSString)
        }
        
        if let familyName = contact.lastName {
            setValueToRecord(person, key: kABPersonLastNameProperty, familyName as NSString)
        }
        
        if let organizationName = contact.organizationName {
            setValueToRecord(person, key: kABPersonOrganizationProperty, organizationName as NSString)
        }
        
        if let middleName = contact.middleName {
            setValueToRecord(person, key: kABPersonMiddleNameProperty, middleName as NSString)
        }
        
        return person
    }
    internal class func createMultiValuesFromLabels(record: ABRecord, type: ABPropertyID, labels:[AddressBookRecordLabel]?) -> ABMutableMultiValue {
        let multiValue = createMultiValue(type)
        let labels = labels ?? [AddressBookRecordLabel]()
        for var adressBookLabel in labels {
            addLabelToMultiValue(multiValue, label: adressBookLabel)
        }
        return multiValue
    }
    
    internal class func addLabelToMultiValue(multivalue: ABMutableMultiValue, label: AddressBookRecordLabel) {
        ABMultiValueAddValueAndLabel(multivalue, label.value, AddressBookRecordLabel.convertLabel(abMappings, label: label.label), nil)
    }
    
    internal class func createMultiValue(type: ABPropertyID) -> ABMutableMultiValue {
        return ABMultiValueCreateMutable(ABPersonGetTypeOfProperty(type)).takeRetainedValue()
    }
    
    internal class func setValueToRecord<T : AnyObject>(record : ABRecord!, key : ABPropertyID, _ value : T?) {
        ABRecordSetValue(record, key, value, nil)
    }
    
    
    internal class func getPropertyFromRecord<T>(record: ABRecord, propertyName : ABPropertyID) -> T? {
        let value: AnyObject? = ABRecordCopyValue(record, propertyName)?.takeRetainedValue()
        return value as? T
    }
    
    internal class func getMultiValues(record: ABRecord, propertyName : ABPropertyID) -> [AddressBookRecordLabel] {
        var array = [AddressBookRecordLabel]()
        let multivalue : ABMultiValue = getPropertyFromRecord(record, propertyName: propertyName) ?? createMultiValue(propertyName)
        
        for i : Int in 0..<(ABMultiValueGetCount(multivalue)) {
            if let addressBookRecordLabel = getAddressBookRecordLabelFromMultiValue(multivalue, i: i) {
                array.append(addressBookRecordLabel)
            }
        }
        return array
    }
    
    internal class func getAddressBookRecordLabelFromMultiValue(multivalue: ABMultiValue, i: Int) -> AddressBookRecordLabel? {
        let mappings = DictionaryUtils.dictionaryWithSwappedKeysAndValues(abMappings)
        return getAddressBookRecordLabelFromMultiValue(multivalue, i: i, labelMappings: mappings)
    }
    
    internal class func getAddressBookRecordLabelFromMultiValue(multivalue: ABMultiValue, i: Int, labelMappings: Dictionary<String, String>) -> AddressBookRecordLabel? {
        let value = ABMultiValueCopyValueAtIndex(multivalue, i).takeRetainedValue() as? String
        
        if let v = value {
            let optionalCFLabel = ABMultiValueCopyLabelAtIndex(multivalue, i)?.takeRetainedValue()
            var optionalLabel: String?
            if let cfLabel = optionalCFLabel {
                optionalLabel = cfLabel as String?
            }
            return AddressBookRecordLabel(label: AddressBookRecordLabel.convertLabel(labelMappings, label: optionalLabel), value: v)
        } else {
            return nil
        }
    }
}