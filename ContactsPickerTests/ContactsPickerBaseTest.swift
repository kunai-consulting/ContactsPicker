//
//  ContactsPickerBaseTest.swift
//  ContactsPicker
//
//  Created by Piotr on 01/12/15.
//  Copyright © 2015 kunai. All rights reserved.
//

import XCTest
@testable import ContactsPicker
import JPSimulatorHacks

// TODO: Skip tests from here and only call CNAddressBookTest & ABAddressBookTest suites ?
public class ContactsPickerBaseTest : XCTestCase {
    
    internal var addressBook: MyAddressBook!
    
    internal var factory: InternalAddressBookFactory {
        get {
            return APIVersionAddressBookFactory()
        }
    }
    
    override public func setUp() {
        super.setUp()
        addressBook = MyAddressBook(factory: factory)
        JPSimulatorHacks.grantAccessToAddressBook()
    }
    
    override public func tearDown() {
        super.tearDown()
        addressBook.deleteAllContacts()
        XCTempAssertNoThrowError{
            try self.addressBook.commitChanges()
        }
    }
    
    func testAddressBookAccess() {
        let expectation = self.expectationWithDescription("request access")

        addressBook.requestAccess { (access) -> Void in
            XCTAssertTrue(access)
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testAddingAContact() {
        let numberOfContacts = addressBook.personCount
        let contact = addTestContact()
        commitChanges()
        XCTAssertEqual(numberOfContacts + 1, addressBook.personCount)
        XCTAssertNotNil(addressBook.findContactWithIdentifier(contact.identifier))
    }
    
    func testDeletingContact() {
        let contact = addTestContact()
        commitChanges()
        let id = contact.identifier
        addressBook.deleteContactWithIdentifier(id)
        commitChanges()
        XCTAssertNil(addressBook.findContactWithIdentifier(id))
    }
}

internal extension ContactsPickerBaseTest {
    func addTestContact() -> KunaiContact {
        let contact = KunaiContact()
        contact.firstName = "A"
        contact.lastName = "B"
        addressBook.addContact(contact)
        return contact
    }
    
    func commitChanges() {
        XCTempAssertNoThrowError{
            try self.addressBook.commitChanges()
        }
    }
}