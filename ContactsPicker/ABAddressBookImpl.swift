//
//  ABAddressBookImpl.swift
//  ContactsPicker
//
//  Created by Piotr on 24/11/15.
//  Copyright © 2015 kunai. All rights reserved.
//

import Foundation
import AddressBook

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
    
    func addContact(contact: KunaiContact) throws {
        let adapter = ABAdapter(kunaiContact: contact)
        let record = adapter.convertedObject
    
        ABAddressBookAddRecord(addressBook, record, nil)
        
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

internal class ABRecordWrapper {
    internal let abRecord: ABRecord!
    
    internal init(abRecord:ABRecord!) {
        self.abRecord = abRecord
    }
}

internal class ABAdapter: KunaiContactAdapter<ABRecord> {
    
    override var mappings: [String:String] {
        get {
            return [
                KunaiLabeledValue.LabelMain : kABPersonPhoneMainLabel as String,
                KunaiLabeledValue.LabelHome : kABPersonHomePageLabel as String,
                KunaiLabeledValue.LabelWork : kABWorkLabel as String,
                KunaiLabeledValue.LabelOther : kABOtherLabel as String,
                KunaiLabeledValue.LabelPhoneiPhone : kABPersonPhoneIPhoneLabel as String,
                KunaiLabeledValue.LabelPhoneMobile : kABPersonPhoneMobileLabel as String
            ]
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
