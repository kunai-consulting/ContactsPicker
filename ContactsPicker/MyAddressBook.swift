//
//  MyAddressBook.swift
//  ContactsPicker
//
//  Created by Piotr on 23/11/15.
//  Copyright © 2015 kunai. All rights reserved.
//

import Foundation
import AddressBook
import Contacts

protocol InternalAddressBook {
    var personCount: Int {
        get
    }
    
    func requestAccess( completion: (Bool) -> Void );
}

private class ABAddressBookImpl: InternalAddressBook {
    
    private var addressBook: ABAddressBook!
    
    private init() {
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
    
    private func requestAccess(completion: (Bool) -> Void) {
        ABAddressBookRequestAccessWithCompletion(addressBook) {
            (let b : Bool, c : CFError!) -> Void in
            completion(b)
        }
    }
}

private class CNAddressBookImpl: InternalAddressBook {
    
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
    
    private init() {
        contactStore = CNContactStore()
    }
    
    private func requestAccess(completion: (Bool) -> Void) {
        contactStore.requestAccessForEntityType(CNEntityType.Contacts) { (access, err) -> Void in
            completion(access)
        }
    }
    
}

public class MyAddressBook {
    private var internalAddressBook: InternalAddressBook!
    
    public var personCount : Int {
        get {
            return internalAddressBook.personCount;
        }
    }
    
    public init() {
        
        let isOnIOS9OrAbove = NSProcessInfo().isOperatingSystemAtLeastVersion(
            NSOperatingSystemVersion(majorVersion: 9, minorVersion: 0, patchVersion: 0)
        );
            
        if isOnIOS9OrAbove {
            print("iOS >=  9.0.0")
            internalAddressBook = CNAddressBookImpl()
        } else {
            print("iOS < 9")
            internalAddressBook = ABAddressBookImpl()
        }
    }
    
    public func requestAccessWithCompletion( completion : (Bool) -> Void ) {
        internalAddressBook.requestAccess(completion);
    }
}