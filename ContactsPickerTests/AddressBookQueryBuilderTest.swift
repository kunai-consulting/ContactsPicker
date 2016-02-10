//
//  AddressBookQueryTest.swift
//  ContactsPicker
//
//  Created by Piotr on 07/12/15.
//  Copyright © 2015 kunai. All rights reserved.
//

import Foundation
import XCTest
@testable import ContactsPicker
import JPSimulatorHacks

// TODO : move to generic XCTestCases ?
internal class CNAddressBookQueryBuilderTest : XCTestCase {

    override func setUp() {
        super.setUp()
        JPSimulatorHacks.grantAccessToAddressBook()
    }
    
    func testSettingPredicate() {
        let queryBuilder = CNAddressBookQueryBuilder(addressBook: CNAddressBookImpl())
        let predicate: ContactPredicate = { contact in
            return true
        }
        queryBuilder.matchingPredicate(predicate)
        if let queryPredicate = queryBuilder.predicate {
            XCTAssertTrue(queryPredicate(contat: AddressBookRecord()))
        } else {
            XCTFail("empty predicate")
        }
    }
}

internal class ABAddressBookQueryBuilderTest : XCTestCase {
    
    func testSettingPredicate() {
        XCTempAssertNoThrowError {
            let queryBuilder = ABAddressBookQueryBuilder(addressBook: try ABAddressBookImpl())
            let predicate: ContactPredicate = { contact in
                return true
            }
            queryBuilder.matchingPredicate(predicate)
            if let queryPredicate = queryBuilder.predicate {
                XCTAssertTrue(queryPredicate(contat: AddressBookRecord()))
            } else {
                XCTFail("empty predicate")
            }
        }

    }
}