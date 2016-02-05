//
//  CNAddressBookQueryBuilder.swift
//  ContactsPicker
//
//  Created by Piotr on 07/12/15.
//  Copyright © 2015 kunai. All rights reserved.
//

import Foundation
import Contacts

@available(iOS 9.0, *)
internal class CNAddressBookQueryBuilder: InternalAddressBookQueryBuilder<CNAddressBookImpl> {
    
    let addressBookPropertiesToCNProperties: [AddressBookRecordProperty: String] = [
        AddressBookRecordProperty.FirstName : CNContactGivenNameKey,
        AddressBookRecordProperty.MiddleName : CNContactMiddleNameKey,
        AddressBookRecordProperty.LastName : CNContactFamilyNameKey,
        AddressBookRecordProperty.EmailAddresses : CNContactEmailAddressesKey,
        AddressBookRecordProperty.OrganizationName : CNContactOrganizationNameKey,
        AddressBookRecordProperty.PhoneNumbers : CNContactPhoneNumbersKey
    ]
    
    
    internal override init(addressBook: CNAddressBookImpl) {
        super.init(addressBook: addressBook)
    }
    
    override func queryImpl() throws -> [ContactProtocol] {
        let cnKeysToFetch = mapProperties(keysToFetch)
        let contacts = try addressBook.fetchContactsUsingPredicate(addressBook.allContactsPredicate, keys: cnKeysToFetch)
        return contacts
    }
    
    func mapProperties(properties: [AddressBookRecordProperty]) -> [String] {
        let setProperties = Set<AddressBookRecordProperty>(properties)
        var keys = [String]()
        for property in setProperties {
            if let cnProperty = addressBookPropertiesToCNProperties[property] {
                keys.append(cnProperty)
            }
        }
        return keys
    }
}
    