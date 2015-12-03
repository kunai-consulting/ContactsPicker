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

public class ContactsPickerBaseTest : XCTestCase {
    
    internal var addressBook: MyAddressBook!
    
    internal var factory: InternalAddressBookFactory {
        get {
            return APIVersionAddressBookFactory()
        }
    }
    
    // call CNAddressBookTest & ABAddressBookTest suites only
    override public func performTest(run: XCTestRun) {
        if self.dynamicType != ContactsPickerBaseTest.self {
            super.performTest(run)
        }
    }
    
    override public func setUp() {
        super.setUp()
        XCTempAssertNoThrowError { () -> () in
            self.addressBook = try MyAddressBook(factory: self.factory)
        }
        
        JPSimulatorHacks.grantAccessToAddressBook()
        requestAccess()
    }
    
    override public func tearDown() {
        super.tearDown()

        XCTempAssertNoThrowError{
            try self.addressBook.deleteAllContacts()
            try self.addressBook.commitChanges()
        }
    }
    
    func requestAccess() {
        let expectation = self.expectationWithDescription("request access")

        addressBook.requestAccessToAddressBook({ (access, error) -> Void in
            XCTAssertTrue(access)
            expectation.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testAddingAContact() {
        let numberOfContacts = try! addressBook.retrieveRecordsCount()
        let contact = addTestContact()
        commitChanges()
        XCTAssertEqual(numberOfContacts + 1, try! addressBook.retrieveRecordsCount())
        
        let savedContact = addressBook.findContactWithIdentifier(contact.identifier)
        XCTAssertNotNil(savedContact)
        XCTAssertEqual(contact.firstName, savedContact?.firstName)
        XCTAssertEqual(contact.lastName, savedContact?.lastName)
        
    }
    
    func testUpdatingContact() {
        let contact = addTestContact()
        commitChanges()
        var savedContact = addressBook.findContactWithIdentifier(contact.identifier)
        savedContact!.firstName = "NewName"
        addressBook.updateContact(savedContact!)
        commitChanges()
        XCTAssertEqual("NewName", addressBook.findContactWithIdentifier(contact.identifier)?.firstName)
    }
    
    func testDeletingContact() {
        let contact = addTestContact()
        commitChanges()
        let id = contact.identifier
        XCTempAssertNoThrowError { () -> () in
            try self.addressBook.deleteContactWithIdentifier(id)
        }
        
        commitChanges()
        XCTAssertNil(addressBook.findContactWithIdentifier(id))
    }
}

internal extension ContactsPickerBaseTest {
    func addTestContact() -> FetchedContactValues {
        let contact = NewContactValues()
        contact.firstName = "A"
        contact.lastName = "B"
        return try! self.addressBook.addContact(contact)
    }
    
    func commitChanges() {
        XCTempAssertNoThrowError{
            try self.addressBook.commitChanges()
        }
    }
}