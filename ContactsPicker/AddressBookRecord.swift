//
//  AddressBookRecord.swift
//  ContactsPicker
//
//  Created by Piotr on 04/12/15.
//  Copyright © 2015 kunai. All rights reserved.
//

import Foundation

public class AddressBookRecord: ContactProtocol {
    
    public var identifier: String? {
        get {
            return nil
        }
    }
    
    public var firstName: String?
    
    public var lastName: String?
    
    public var phoneNumbers: [AddressBookRecordLabel]?
    
    public var emailAddresses: [AddressBookRecordLabel]?
    
    public var organizationName: String?
    
    public var middleName: String?
    
    public init() {
        phoneNumbers = [AddressBookRecordLabel]()
        emailAddresses = [AddressBookRecordLabel]()
    }
    
    public convenience init(firstName: String, lastName: String) {
        self.init()
        self.firstName = firstName
        self.lastName = lastName
    }
    
}