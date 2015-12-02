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

private let IdentifierKey = "identifier"
private let FirstNameKey = "firstName"
private let LastNameKey = "lastName"
private let PhoneNumbersKey = "phoneNumbers"
private let EmailAddressesKey = "emails"
private let OrganizationKey = "organization"

public protocol ContactToInsert {
    
    var firstName: String? {
        get set
    }
    
    var lastName: String? {
        get set
    }
    
    var phoneNumbers: [KunaiLabeledValue]? {
        get set
    }
    
    var emailAddresses: [KunaiLabeledValue]? {
        get set
    }
    
    var organizationName: String? {
        get set
    }
}

public protocol AlreadySavedContact : ContactToInsert {
    var identifier: String? {
        get
    }
}

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

public class KunaiContact: ContactToInsert {
    
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
