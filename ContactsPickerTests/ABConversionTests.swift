//
//  ABConversionTests.swift
//  ContactsPicker
//
//  Created by Piotr on 04/12/15.
//  Copyright © 2015 kunai. All rights reserved.
//

import Foundation
import XCTest
@testable import ContactsPicker
import AddressBook

internal class ABConversionTests: XCTestCase {
    
    var record: ABRecord!
    
    override func setUp() {
        super.setUp()
        record = ABPersonCreate().takeRetainedValue()
    }
    
    func testConvertingNilLabel() {
        let multiValue = ABRecordAdapter.createMultiValue(kABPersonPhoneProperty)
        ABRecordAdapter.addLabelToMultiValue(multiValue, label: AddressBookRecordLabel(label: nil, value: "123-456-789"))

        let addressBookLabel = ABRecordAdapter.getAddressBookRecordLabelFromMultiValue(multiValue, i: 0)
        XCTAssertNotNil(addressBookLabel)
        XCTAssertNil(addressBookLabel!.label)
        XCTAssertEqual("123-456-789", addressBookLabel!.value as? String)
    }
    
    func testConvertingTypedLabel() {
        
        let multiValue = ABRecordAdapter.createMultiValuesFromLabels(record, type: kABPersonPhoneProperty, labels: [
                AddressBookRecordLabel(label: .Home, value: "123")
            ])
        
        let addressBookLabel = ABRecordAdapter.getAddressBookRecordLabelFromMultiValue(multiValue, i: 0)
        XCTAssertNotNil(addressBookLabel)
        XCTAssertEqual(AddressBookRecordLabel.LabelType.Home.rawValue, addressBookLabel?.label)
    }
}