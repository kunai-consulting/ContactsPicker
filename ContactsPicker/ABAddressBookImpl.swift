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
    
    func addContact(contact: KunaiContact) {
        let adapter = ABAdapter(kunaiContact: contact)
        let record = adapter.convertedObject?.abRecord
        var err : Unmanaged<CFError>? = nil
    
        var success = ABAddressBookAddRecord(addressBook, record, &err)
        print(success)
        ABAddressBookSave(addressBook, &err)
    }
}

internal class ABRecordWrapper {
    internal let abRecord: ABRecord!
    
    internal init(abRecord:ABRecord!) {
        self.abRecord = abRecord
    }
}

internal class ABAdapter: KunaiContactAdapter<ABRecordWrapper> {
    
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
    
    override var convertedObject: ABRecordWrapper? {
        get {
            return ABRecordWrapper(abRecord: toABRecordRef())
        }
    }
    
    internal override init(kunaiContact: KunaiContact) {
        super.init(kunaiContact: kunaiContact)
    }
    
    internal func toABRecordRef() -> ABRecord {
        let person = ABPersonCreate().takeRetainedValue()
        
        if let phoneNumbers = kunaiContact.phoneNumbers {
            let phoneNumberMultiValue: ABMutableMultiValue = ABMultiValueCreateMutable(ABPersonGetTypeOfProperty(kABPersonPhoneProperty)).takeRetainedValue()
            
            for var phoneNumberLabeledValue in phoneNumbers {
                ABMultiValueAddValueAndLabel(phoneNumberMultiValue, phoneNumberLabeledValue.value, convertLabel(phoneNumberLabeledValue.label), nil)
            }
            setValueToRecord(person, key: kABPersonPhoneProperty, phoneNumberMultiValue)
        }
        
        if let emailAddresses = kunaiContact.emailAddresses {
            // TODO
        }
        
        if let firstName = kunaiContact.firstName {
            setValueToRecord(person, key: kABPersonFirstNameProperty, firstName as NSString)
        }
        
        if let familyName = kunaiContact.lastName {
            setValueToRecord(person, key: kABPersonLastNameProperty, familyName as NSString)
        }
        
        return person
    }
    
    private func setValueToRecord<T : AnyObject>(record : ABRecord!, key : ABPropertyID, _ value : T?) {
        ABRecordSetValue(record, key, value, nil)
    }

}
