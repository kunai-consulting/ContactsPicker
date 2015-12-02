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
    
    func addContact(contact: ContactToInsert) -> AlreadySavedContact {
        let record = ABRecordAdapter.toABRecordRef(contact)
        ABAddressBookAddRecord(addressBook, record, nil)
        return ABContactRecord(abRecord: record)
    }
    
    func updateContact(contact: AlreadySavedContact) {
        
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
    
    func findContactWithIdentifier(identifier: String?) -> AlreadySavedContact? {
        
        guard let id = identifier else {
            return nil
        }
        
        if let recordID = Int32(id) {
            if let record = ABAddressBookGetPersonWithRecordID(addressBook, recordID)?.takeUnretainedValue() {
                return ABContactRecord(abRecord: record)
            } else {
                return nil
            }

        } else {
            return nil
        }
    }
    
    func commitChanges() throws {
        if let err = save() {
            print("commit error: \(err.localizedDescription)")
            throw err
        }
    }
    
    internal func save() -> NSError? {
        return errorIfNoSuccess {
            return ABAddressBookSave(self.addressBook, $0)
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


