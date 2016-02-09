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
    
    internal var addressBook: AddressBook!
    
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
            self.addressBook = try AddressBook(factory: self.factory)
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

        if addressBook == nil {
            XCTFail("addressBook is nil!")
            return
        }
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
    
    func testSavingMiddleName() {
        let contact = AddressBookRecord(firstName: "First", lastName: "Last")
        contact.middleName = "middle"
        let savedContact = try! addressBook.addContactToAddressBook(contact)
        commitChanges()
        
        let fetchedContact = addressBook.findContactWithIdentifier(savedContact.identifier)
        XCTAssertEqual("middle", fetchedContact?.middleName)
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
            XCTAssertEqual(2, fetchedContact?.phoneNumbers?.count)
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
    
    func addContactsAndCommit(names:[String]) {
        
        for name in names {
            let components = name.componentsSeparatedByString(" ")
            let firstName = components[0]
            let lastName = components[1]
            XCTempAssertNoThrowError { () -> () in
                try self.addressBook.addContactToAddressBook(AddressBookRecord(firstName: firstName, lastName: lastName))
            }
        }
        commitChanges()
    }
    
    func addNumberOfContactsAndCommit(numberOfContacts: Int) {
        for i in 0..<numberOfContacts {
            XCTempAssertNoThrowError { () -> () in
                let record = AddressBookRecord(firstName: "\(i)", lastName: "\(-i)")
                record.phoneNumbers = [AddressBookRecordLabel(label: .Home, value: "111")]
                record.emailAddresses = [AddressBookRecordLabel(label: .Work, value: "test@mail.com")]
                record.organizationName = "Organization"
                record.middleName = "Middle"
                try self.addressBook.addContactToAddressBook(record)
            }
        }
        
        commitChanges()
    }
    
    func fetchProperties(properties: [AddressBookRecordProperty]) -> [ContactProtocol] {
        let queryBuilder = self.addressBook.queryBuilder().keysToFetch(properties)
        do {
            let results = try queryBuilder.query()
            return results
        } catch let e {
            XCTFail()
            return [ContactProtocol]()
        }
    }
    
    func deleteContactAndCommit(identifier: String) {
        XCTempAssertNoThrowError{
            try self.addressBook.deleteContactWithIdentifier(identifier)
        }
        commitChanges()
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

// getting all contacts or by name
internal extension ContactsPickerBaseTest {
    func testGettingAllContacts() {
        addTestContactAndCommitChange()
        let contacts = try! addressBook.findAllContacts()
        XCTAssertEqual(contacts.count, 1)
        if contacts.indices ~= 0 {
            deleteContactAndCommit(contacts[0].identifier!)
            XCTAssertEqual(0, try! addressBook.retrieveAddressBookRecordsCount())
        }

    }
    
    func testGettingContactsMatchingName() {
        addContactsAndCommit(["A B", "X Y"])
        
        let contactsMatchingB = try! addressBook.findContactsMatchingName("B")
        XCTAssertEqual(1, contactsMatchingB.count)
        if contactsMatchingB.indices ~= 0 {
            let matchingContact = contactsMatchingB[0]
            XCTAssertEqual("A", matchingContact.firstName)
            XCTAssertEqual("B", matchingContact.lastName)
        }
    }
    
}

// querying
internal extension ContactsPickerBaseTest {
    
    func testGettingContactsUsingPredicate() {
        addContactsAndCommit(["VeryVeryVeryLong Name", "Short 1", "Short 2"])
        let predicateForLongName: ContactPredicate = { contact in
            return contact.fullName?.characters.count > 10
        }
        
        XCTempAssertNoThrowError { () -> () in
            let queryBuilder = self.addressBook.queryBuilder().matchingPredicate(predicateForLongName)
            let contactsWithLongName = try queryBuilder.query()
            XCTAssertEqual(contactsWithLongName.count, 1)
            
            if contactsWithLongName.indices ~= 0 {
                XCTAssertEqual("VeryVeryVeryLong Name", contactsWithLongName[0].fullName)
            }
            
        }

    }
    
    func testGettingContactsUsingPredicateWhichAlwaysReturnsFalse() {
        addContactsAndCommit(["name 1", "name 2", "name 3", "name 4"])
        let brutalPredicate: ContactPredicate = { contact in
            return false
        }

        XCTempAssertNoThrowError { () -> () in
            let queryBuilder = self.addressBook.queryBuilder().matchingPredicate(brutalPredicate)
            let resultCount = try queryBuilder.query().count
            XCTAssertEqual(0, resultCount)
        }
        
    }
    
    func testGettingContactsAsync() {
        addContactsAndCommit(["name 1", "name 2"])
        let queryBuilder = addressBook.queryBuilder().keysToFetch([.Identifier])
        let expectation = self.expectationWithDescription("async query")
        
        queryBuilder.queryAsync { (results, error) -> () in
            XCTAssertNotNil(results)
            XCTAssertEqual(2, results!.count)
            XCTAssertNil(error)
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testGettingAllKeys() {
        addNumberOfContactsAndCommit(3)
        for contact in fetchProperties(AddressBookRecordProperty.allValues) {
            XCTAssertTrue(contact.hasAllProperties())
        }
    }
    
    func testGettingFewKeys() {
        addNumberOfContactsAndCommit(3)
        let keysToFetch: [AddressBookRecordProperty] = [.Identifier, .PhoneNumbers, .OrganizationName]
        let unincludedKeys = Set(AddressBookRecordProperty.allValues).subtract(keysToFetch)
        for contact in fetchProperties(keysToFetch) {
            XCTAssertTrue(contact.hasProperties(keysToFetch))
            XCTAssertFalse(contact.hasProperties(Array(unincludedKeys)))
        }
        
    }
    
    func testGettingOIdentifierOnly() {
        addNumberOfContactsAndCommit(3)
        for contact in fetchProperties([.Identifier]) {
            XCTAssertTrue(contact.hasProperty(.Identifier))
            XCTAssertFalse(contact.hasProperty(.FirstName))
        }
    }
}

typealias PropertyMapper = (contact: ContactProtocol) -> AnyObject?
let mappings: [AddressBookRecordProperty: PropertyMapper] = [
    AddressBookRecordProperty.Identifier : { contact in
        return contact.identifier
    },
    AddressBookRecordProperty.FirstName : { contact in
        return contact.firstName
    },
    AddressBookRecordProperty.LastName : { contact in
        return contact.lastName
    },
    AddressBookRecordProperty.MiddleName: { contact in
        return contact.middleName
    },
    AddressBookRecordProperty.EmailAddresses : { contact in
        return contact.emailAddresses
    },
    AddressBookRecordProperty.PhoneNumbers : { contact in
        return contact.phoneNumbers
    },
    AddressBookRecordProperty.OrganizationName : { contact in
        return contact.organizationName
    }
]

internal extension ContactProtocol {
    
    internal func mapProperty(property: AddressBookRecordProperty) -> AnyObject? {
        return mappings[property]?(contact:self)
    }
    
    internal func hasProperty(property: AddressBookRecordProperty) -> Bool {
        return mapProperty(property) != nil
    }
    
    internal func hasAllProperties() -> Bool {
        return hasProperties(AddressBookRecordProperty.allValues)
    }
    
    internal func hasAllEmptyProperties() -> Bool {
        return !hasAllProperties()
    }
    
    internal func hasProperties(properties: [AddressBookRecordProperty]) -> Bool {
        for property in properties {
            if !hasProperty(property) {
                print("missing property \(property)")
                return false
            }
        }
        return true;
    }
}