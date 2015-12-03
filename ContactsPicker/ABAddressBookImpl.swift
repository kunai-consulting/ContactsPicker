//
//  ABAddressBookImpl.swift
//  ContactsPicker
//
//  Created by Piotr on 24/11/15.
//  Copyright © 2015 kunai. All rights reserved.
//

import Foundation
import AddressBook

@available(iOS 8.0, *)
internal class ABAddressBookImpl: InternalAddressBook {
    
    private var addressBook: ABAddressBook!
    
    internal init() throws {
        var err : Unmanaged<CFError>? = nil
        let ab = ABAddressBookCreateWithOptions(nil, &err)
        if err == nil {
            addressBook = ab.takeRetainedValue()
        } else {
            if let error = err?.takeRetainedValue() {
                throw error
            }
        }
    }
    
    func requestAccessToAddressBook(completion: (Bool, NSError?) -> Void) {
        ABAddressBookRequestAccessWithCompletion(addressBook) {
            (let access : Bool, error : CFError!) -> Void in
            if access {
                completion(access, nil)
            } else {
                completion(access, error as NSError)
            }
        }
    }
    
    func retrieveRecordsCount() throws -> Int {
        return ABAddressBookGetPersonCount(addressBook);
    }
    
    
    func addContact(contact: ContactValues) throws -> FetchedContactValues {
        let record = ABRecordAdapter.toABRecordRef(contact)
        
        if let error = (errorIfNoSuccess({
            ABAddressBookAddRecord(self.addressBook, record, $0)
        })) {
            throw error
        } else {
            return ABContactRecord(abRecord: record)
        }
    }
    
    func updateContact(contact: FetchedContactValues) {
        
    }
    
    func deleteContactWithIdentifier(identifier: String?) throws {
        guard let id = identifier else {
            return
        }
        
        
        guard let recordID = Int32(id) else {
            return
        }
        
        let record = ABAddressBookGetPersonWithRecordID(addressBook, recordID).takeUnretainedValue()
        if let error = (errorIfNoSuccess({
            return ABAddressBookRemoveRecord(self.addressBook, record, $0)
        })) {
            throw error
        }
 
    }
    
    func deleteAllContacts() throws {
        let allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue()
        let allRecordsArray = allPeople as NSArray? as? [ABRecord]
        
        if let allRecords = allRecordsArray {
            for var person in allRecords {
                if let error = (errorIfNoSuccess({
                    return ABAddressBookRemoveRecord(self.addressBook, person, $0)
                })) {
                    throw error
                }
            }
        }

    }
    
    func findContactWithIdentifier(identifier: String?) -> FetchedContactValues? {
        
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


