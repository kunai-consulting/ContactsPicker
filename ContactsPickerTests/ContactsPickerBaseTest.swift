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
    
    internal var factory: AddressBookFactory {
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
            try self.addressBook.commitChangesToAddressBook()
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
        let numberOfContacts = try! addressBook.retrieveAddressBookRecordsCount()
        addTestContactAndCommitChange()
        XCTAssertEqual(numberOfContacts + 1, try! addressBook.retrieveAddressBookRecordsCount())
    }
    
    func testFidningContactById() {
        let savedContact = addressBook.findContactWithIdentifier(addTestContactAndCommitChange().identifier)
        XCTAssertNotNil(savedContact)
        XCTAssertEqual("A", savedContact?.firstName)
        XCTAssertEqual("B", savedContact?.lastName)
    }
    
    func testSavingPhoneNumbers() {
        let contact = AddressBookRecord()
        let phoneNumber1 = AddressBookRecordLabel(label: .Home, value: "111-222-333")
        let phoneNumber2 = AddressBookRecordLabel(label: nil, value: "444-555-666")
        
        contact.phoneNumbers = [phoneNumber1, phoneNumber2]
        
        let savedContact = try! addressBook.addContactToAddressBook(contact)
        commitChanges()
        
        let fetchedContact = addressBook.findContactWithIdentifier(savedContact.identifier)
        let phoneNumbers = fetchedContact?.phoneNumbers
        XCTAssertNotNil(phoneNumbers)
        XCTAssertEqual(2, phoneNumbers?.count)
        
        let fetchedNumber1 = phoneNumbers![0]
        let fetchedNumber2 = phoneNumbers![1]
        
        // test values
        XCTAssertEqual("111-222-333", fetchedNumber1.value as? String)
        XCTAssertEqual("444-555-666", fetchedNumber2.value as? String)
        
        // test labels
        let number1Label = fetchedNumber1.label
        let number2Label = fetchedNumber2.label
        XCTAssertEqual(AddressBookRecordLabel.LabelType.Home.rawValue, number1Label)
        XCTAssertNil(number2Label)
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
    
    func testSavingTheSamePhoneNumberTwice() {
        let contact = AddressBookRecord()
        contact.firstName = "IAmRepeatingMyself"
        contact.phoneNumbers = [ AddressBookRecordLabel(label: nil, value: "111"), AddressBookRecordLabel(label: nil, value: "111")]
        
      
        XCTempAssertNoThrowError { () -> () in
            let savedContact = try self.addressBook.addContactToAddressBook(contact)
            try self.addressBook.commitChangesToAddressBook()
            let fetchedContact = self.addressBook.findContactWithIdentifier(savedContact.identifier)
            let fetchedNumbers = fetchedContact?.phoneNumbers
            // What is correct behaviour?
            // XCTAssertEqual(1, fetchedContact?.phoneNumbers?.count) 
        }
        
        
    }
    
    func testDeletingContact() {
        let contact = addTestContactAndCommitChange()
        let id = contact.identifier
        XCTempAssertNoThrowError { () -> () in
            try self.addressBook.deleteContactWithIdentifier(id)
        }
        
        commitChanges()
        XCTAssertNil(addressBook.findContactWithIdentifier(id))
    }
}

internal extension ContactsPickerBaseTest {
    func addTestContact() -> ContactProtocol {
        let contact = AddressBookRecord()
        contact.firstName = "A"
        contact.lastName = "B"
        return try! self.addressBook.addContactToAddressBook(contact)
    }
    
    func addTestContactAndCommitChange() -> ContactProtocol {
        let savedContact = addTestContact()
        XCTempAssertNoThrowError{
            try self.addressBook.commitChangesToAddressBook()
        }
        return savedContact
    }
    
    func commitChanges() {
        XCTempAssertNoThrowError{
            try self.addressBook.commitChangesToAddressBook()
        }
    }
}