//
//  ContactsPicker
//
//  Created by Piotr on 24/11/15.
//  Copyright © 2015 kunai. All rights reserved.
//

import Foundation
import Contacts
import AddressBook

public protocol ContactValues {
    
    var firstName: String? {
        get set
    }
    
    var lastName: String? {
        get set
    }
    
    var phoneNumbers: [LabeledValue]? {
        get set
    }
    
    var emailAddresses: [LabeledValue]? {
        get set
    }
    
    var organizationName: String? {
        get set
    }
}

public protocol FetchedContactValues : ContactValues {
    var identifier: String? {
        get
    }
}

public class LabeledValue {
    
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

public class NewContactValues: ContactValues {
    
    public var firstName: String?
    
    public var lastName: String?
    
    public var phoneNumbers: [LabeledValue]?
    
    public var emailAddresses: [LabeledValue]?
    
    public var organizationName: String?
    
    public init() {
        phoneNumbers = [LabeledValue]()
        emailAddresses = [LabeledValue]()
    }
    
}
