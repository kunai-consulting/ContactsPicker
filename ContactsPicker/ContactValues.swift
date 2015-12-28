//
//  ContactsPicker
//
//  Created by Piotr on 24/11/15.
//  Copyright © 2015 kunai. All rights reserved.
//

import Foundation
import Contacts
import AddressBook

public protocol ContactProtocol {
    
    var identifier: String? {
        get
    }
    
    var firstName: String? {
        get set
    }
    
    var middleName: String? {
        get set 
    }
    
    var lastName: String? {
        get set
    }
    
    var phoneNumbers: [AddressBookRecordLabel]? {
        get set
    }
    
    var emailAddresses: [AddressBookRecordLabel]? {
        get set
    }
    
    var organizationName: String? {
        get set
    }
}

public extension ContactProtocol {
    var fullName: String? {
        get {
            if firstName == nil && lastName == nil {
                return nil
            }
            
            if firstName != nil && lastName == nil {
                return firstName
            }
            
            if firstName == nil && lastName != nil {
                return lastName
            }
            
            return "\(firstName!) \(lastName!)"
        }
    }
}

public class AddressBookRecordLabel {

    public enum LabelType: String {
        case Main = "LabelMain"
        case Home = "LabelHome"
        case Work = "LabelWork"
        case Other = "LabelOther"
        case PhoneiPhone = "LabelPhoneiPhone"
        case PhoneMobile = "LabelPhoneMobile"
    }

    public var label: String?
    public var value: protocol<NSCopying, NSSecureCoding>
    
    public init(label: String?, value: protocol<NSCopying, NSSecureCoding>) {
        self.label = label
        self.value = value
    }
    
    public init(label: LabelType, value: protocol<NSCopying, NSSecureCoding>) {
        self.label = label.rawValue
        self.value = value
    }
    
    internal class func convertLabel(mappings: [String:String], label: String?) -> String? {
        guard let label = label else {
            return nil
        }
        
        guard !label.isEmpty else {
            return nil
        }
        
        if mappings.keys.contains(label) {
            return mappings[label]
        } else {
            return label
        }
    }

}

