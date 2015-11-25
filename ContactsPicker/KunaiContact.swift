//
//  KunaiContact.swift
//  ContactsPicker
//
//  Created by Piotr on 24/11/15.
//  Copyright © 2015 kunai. All rights reserved.
//

import Foundation
import Contacts
import AddressBook

private let FirstNameKey = "firstName"
private let LastNameKey = "lastName"
private let PhoneNumbersKey = "phoneNumbers"
private let EmailAddressesKey = "emails"
private let OrganizationKey = "organization"

public class KunaiLabeledValue {
    
    public static let LabelMain = "LabelMain"
    public static let LabelHome = "LabelHome"
    public static let LabelWork = "LabelWork"
    public static let LabelOther = "LabelOther"
    public static let LabelPhoneiPhone = "LabelPhoneiPhone"
    public static let LabelPhoneMobile = "LabelPhoneMobile"
    
    public var label: String?
    public var value: protocol<NSCopying, NSSecureCoding>
    
    public init(label: String?, value: protocol<NSCopying, NSSecureCoding>) {
        self.label = label
        self.value = value
    }

}

public class KunaiContact {
    
    private var properties = [String: AnyObject]()
    
    public var firstName: String? {
        set {
            properties[FirstNameKey] = newValue
        }

        get {
            return properties[FirstNameKey] as? String
        }
    }
    
    public var lastName: String? {
        set {
            properties[LastNameKey] = newValue
        }

        get {
            return properties[LastNameKey] as? String
        }
    }
    
    public var phoneNumbers: [KunaiLabeledValue]? {
        set {
            properties[PhoneNumbersKey] = newValue
        }

        get {
            return properties[PhoneNumbersKey] as? [KunaiLabeledValue]
        }
    }
    
    public var emailAddresses: [KunaiLabeledValue]? {
        set {
            properties[EmailAddressesKey] = newValue
        }
        
        get {
            return properties[EmailAddressesKey] as? [KunaiLabeledValue]
        }
    }
    
    public var organizationName: String? {
        set {
            properties[OrganizationKey] = newValue
        }
        
        get {
            return properties[OrganizationKey] as? String
        }
    }
    
    
    public init() {
        emailAddresses = [KunaiLabeledValue]()
        phoneNumbers = [KunaiLabeledValue]()
    }
    
}

internal class KunaiContactAdapter<T> {
    
    internal let kunaiContact: KunaiContact
    
    internal var mappings: [String:String] {
        get {
            return [String:String]()
        }
    }
    
    internal var convertedObject: T? {
        get {
            return nil
        }
    }
    
    internal init(kunaiContact: KunaiContact) {
        self.kunaiContact = kunaiContact
    }
    
    internal func convertLabel(label: String?) -> String? {
        guard let label = label else {
            return nil
        }
        
        if mappings.keys.contains(label) {
            return mappings[label]
        } else {
            return label
        }
    }
    
}
