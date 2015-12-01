//
//  ABAddressBookImpl.swift
//  ContactsPicker
//
//  Created by Piotr on 24/11/15.
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

internal class ABAddressBookImpl: InternalAddressBook {
    
    private var addressBook: ABAddressBook!
    
    internal init() {
        var err : Unmanaged<CFError>? = nil
        let ab = ABAddressBookCreateWithOptions(nil, &err)
        if err == nil {
            addressBook = ab.takeRetainedValue()
        }
    }
    
    var personCount: Int {
        get {
            return ABAddressBookGetPersonCount(addressBook);
        }
    }
    
    func requestAccess(completion: (Bool) -> Void) {
        ABAddressBookRequestAccessWithCompletion(addressBook) {
            (let b : Bool, c : CFError!) -> Void in
            completion(b)
        }
    }
    
    func addContact(contact: KunaiContact) {
        let adapter = ABRecordAdapter(kunaiContact: contact)
        let record = adapter.convertedObject
    
        ABAddressBookAddRecord(addressBook, record, nil)
        // record id isn't available before saving changes - how to handle that?
        let recordID = String(ABRecordGetRecordID(record))
        contact.identifierGetter = {
            return String(ABRecordGetRecordID(record))
        }
    }
    
    func deleteContactWithIdentifier(identifier: String?) {
        guard let id = identifier else {
            return
        }
        
        
        guard let recordID = Int32(id) else {
            return
        }
        
        let record = ABAddressBookGetPersonWithRecordID(addressBook, recordID).takeUnretainedValue()
        ABAddressBookRemoveRecord(addressBook, record, nil)
    }
    
    func deleteAllContacts() {
        let allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue()
        let allRecordsArray = allPeople as NSArray? as? [ABRecord]
        
        if let allRecords = allRecordsArray {
            for var person in allRecords {
                ABAddressBookRemoveRecord(addressBook, person, nil)
            }
        }

    }
    
    func findContactWithIdentifier(identifier: String?) -> KunaiContact? {
        
        guard let id = identifier else {
            return nil
        }
        
        if let recordID = Int32(id) {
            if let record = ABAddressBookGetPersonWithRecordID(addressBook, recordID)?.takeUnretainedValue() {
                let adapter = ABKunaiContactAdapter(internalContact: record)
                return adapter.convertedToKunaiContact
            } else {
                return nil
            }

        } else {
            return nil
        }
    }
    
    func commitChanges() throws {
        if let err = save() {
            throw err
        }
    }
    
    internal func save() -> NSError? {
        return errorIfNoSuccess {
            ABAddressBookSave(self.addressBook, $0)
        }
    }
    
    func errorIfNoSuccess(call : (UnsafeMutablePointer<Unmanaged<CFError>?>) -> Bool) -> NSError? {
        var err : Unmanaged<CFError>? = nil
        let success : Bool = call(&err)
        if success {
            return nil
        }
        else {
            if let error = err {
                let cfError = error.takeRetainedValue()
                let nsError: NSError? = cfError as NSError?
                return nsError
            } else {
                return nil
            }
        }
    }
}

internal class ABKunaiContactAdapter : InternalContactAdapter<ABRecord> {
    override var mappings: [String:String] {
        get {
            return abMappings.reversedDictionary
        }
    }
    
    override var convertedToKunaiContact: KunaiContact? {
        get {
            return toKunaiContact()
        }
    }
    
    private override init(internalContact: ABRecord) {
        super.init(internalContact: internalContact)
    }
    
    private func toKunaiContact() -> KunaiContact {
        let abRecord = internalContact
        let kunaiContact = KunaiContact()
        kunaiContact.firstName = getPropertyFromRecord(abRecord, propertyName: kABPersonFirstNameProperty)
        kunaiContact.lastName = getPropertyFromRecord(abRecord, propertyName: kABPersonLastNameProperty)
        kunaiContact.phoneNumbers = getMultiValues(abRecord, propertyName: kABPersonPhoneProperty)
        kunaiContact.emailAddresses = getMultiValues(abRecord, propertyName:  kABPersonEmailProperty)
        kunaiContact.identifier = String(ABRecordGetRecordID(abRecord))
        return kunaiContact
    }
    
    private func getPropertyFromRecord<T>(record: ABRecord, propertyName : ABPropertyID) -> T? {
        let value: AnyObject? = ABRecordCopyValue(record, propertyName)?.takeRetainedValue()
        return value as? T
    }
    
    private func getMultiValues(record: ABRecord, propertyName : ABPropertyID) -> [KunaiLabeledValue] {
        var array = [KunaiLabeledValue]()
        let multivalue : ABMultiValue? = getPropertyFromRecord(record, propertyName: propertyName)
        for i : Int in 0..<(ABMultiValueGetCount(multivalue)) {
            let value = ABMultiValueCopyValueAtIndex(multivalue, i).takeRetainedValue() as? String
            if let v = value {
                let id : Int = Int(ABMultiValueGetIdentifierAtIndex(multivalue, i))
                let optionalLabel = ABMultiValueCopyLabelAtIndex(multivalue, i)?.takeRetainedValue() as? String
                array.append(
                    KunaiLabeledValue(label: convertLabel(optionalLabel), value: v)
                )
            }
        }
        return array
    }
}

internal class ABRecordAdapter: KunaiContactAdapter<ABRecord> {
    
    override var mappings: [String:String] {
        get {
            return abMappings
        }
    }
    
    override var convertedObject: ABRecord? {
        get {
            return toABRecordRef()
        }
    }
    
    internal override init(kunaiContact: KunaiContact) {
        super.init(kunaiContact: kunaiContact)
    }
    
    internal func toABRecordRef() -> ABRecord {
        let person = ABPersonCreate().takeRetainedValue()
        
        if let phoneNumbers = kunaiContact.phoneNumbers {
            let phoneNumberMultiValue = createMultiValue(kABPersonPhoneProperty)

            for var phoneNumberLabeledValue in phoneNumbers {
                ABMultiValueAddValueAndLabel(phoneNumberMultiValue, phoneNumberLabeledValue.value, convertLabel(phoneNumberLabeledValue.label), nil)
            }
            setValueToRecord(person, key: kABPersonPhoneProperty, phoneNumberMultiValue)
        }
        
        if let emailAddresses = kunaiContact.emailAddresses {
            let emailAddressesMultiValue = createMultiValue(kABPersonEmailProperty)
            
            for var emailLabeledValue in emailAddresses {
                ABMultiValueAddValueAndLabel(emailAddressesMultiValue, emailLabeledValue.value, convertLabel(emailLabeledValue.label), nil)
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
    
    private func createMultiValue(type: ABPropertyID) -> ABMutableMultiValue {
        return ABMultiValueCreateMutable(ABPersonGetTypeOfProperty(type)).takeRetainedValue()
    }
    
    private func setValueToRecord<T : AnyObject>(record : ABRecord!, key : ABPropertyID, _ value : T?) {
        ABRecordSetValue(record, key, value, nil)
    }
}
