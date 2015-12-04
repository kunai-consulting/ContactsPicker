//
//  CNConversionTests.swift
//  ContactsPicker
//
//  Created by Piotr on 04/12/15.
//  Copyright © 2015 kunai. All rights reserved.
//

import Foundation
import XCTest
@testable import ContactsPicker
import Contacts

internal class CNConversionTests: XCTestCase {
    
    func testConvertingNilLabel() {
        let sampleValue = CNLabeledValue(label: nil, value: "sample")
        let abValue = convertCNLabeledValue(sampleValue)
        XCTAssertNil(abValue.label)
        XCTAssertEqual("sample", abValue.value as? String)
    }
    
    func testConvertingTypedLabel() {
        let sampleValue = CNLabeledValue(label: CNLabelHome, value: "sample2")
        let abValue = convertCNLabeledValue(sampleValue)
        XCTAssertEqual(AddressBookRecordLabel.LabelType.Home.rawValue, abValue.label)
        XCTAssertEqual("sample2", abValue.value as? String)
    }
    
    func testConvertingPhoneLabeledValues() {
        let samplePhone = CNLabeledValue(label: nil, value: CNPhoneNumber(stringValue: "111-222-333"))
        let abValue = convertCNLabeledValue(samplePhone)
        XCTAssertEqual("111-222-333", abValue.value as? String)
    }
    
    func testConvertingEmailLabeledValues() {
        let sampleEmail = CNLabeledValue(label: nil, value: "sample@gmail.com")
        let abValue = convertCNLabeledValue(sampleEmail)
        XCTAssertEqual("sample@gmail.com", abValue.value as? String)
    }
    
    func convertCNLabeledValue(cnLabel: CNLabeledValue) -> AddressBookRecordLabel {
        return CNAdapter.convertCNLabeledValues([cnLabel])[0]
    }
}