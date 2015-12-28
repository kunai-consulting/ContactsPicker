//
//  AddressBookQueryBuilder.swift
//  ContactsPicker
//
//  Created by Piotr on 07/12/15.
//  Copyright © 2015 kunai. All rights reserved.
//

import Foundation

public typealias ContactPredicate = (contat: ContactProtocol) -> (Bool)
public typealias ContactResults = (results: [ContactProtocol]?, error: ErrorType?) -> ()

public enum AddressBookRecordProperty {
    case Identifier
    case FirstName
    case MiddleName
    case LastName
    case PhoneNumbers
    case EmailAddresses
    case OrganizationName
    
    static let allValues = [
        AddressBookRecordProperty.Identifier,
        AddressBookRecordProperty.FirstName,
        AddressBookRecordProperty.MiddleName,
        AddressBookRecordProperty.LastName,
        AddressBookRecordProperty.PhoneNumbers,
        AddressBookRecordProperty.EmailAddresses,
        AddressBookRecordProperty.OrganizationName
    ]
}


public protocol AddressBookQueryBuilder {
    func keysToFetch(keys: [AddressBookRecordProperty]) -> AddressBookQueryBuilder
    func matchingPredicate(predicate: ContactPredicate) -> AddressBookQueryBuilder
    func query() throws -> [ContactProtocol]
    func queryAsync(completion: ContactResults)
}

internal class InternalAddressBookQueryBuilder<T: AddressBookProtocol>: AddressBookQueryBuilder {
    
    internal var keysToFetch = AddressBookRecordProperty.allValues
    
    internal var predicate: ContactPredicate?
    
    internal let addressBook: T
    
    internal init(addressBook: T) {
        self.addressBook = addressBook
    }
    
    func keysToFetch(keys: [AddressBookRecordProperty]) -> AddressBookQueryBuilder {
        // always include ID
        self.keysToFetch = Array(Set(keys).union([AddressBookRecordProperty.Identifier]))
        return self
    }
    
    func matchingPredicate(predicate: ContactPredicate) -> AddressBookQueryBuilder {
        self.predicate = predicate
        return self
    }
    
    func query() throws -> [ContactProtocol] {
        let contacts = try queryImpl()
        if let predicate = self.predicate {
            return contacts.filter(predicate)
            
        } else {
            return contacts
        }
    }
    
    func queryImpl() throws -> [ContactProtocol] {
        return [ContactProtocol]()
    }
    
    func queryAsync(completion: ContactResults) {
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            do {
                let results = try self.query()
                dispatch_async(dispatch_get_main_queue()) {
                    completion(results: results, error: nil)
                }
            }
            catch let e {
                dispatch_async(dispatch_get_main_queue()) {
                    completion(results: nil, error: e)
                }
            }
            

        }
    }
}