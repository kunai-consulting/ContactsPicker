//
//  ABAddressBookTest.swift
//  ContactsPicker
//
//  Created by Piotr on 01/12/15.
//  Copyright © 2015 kunai. All rights reserved.
//

import Foundation
@testable import ContactsPicker

public class ABAddressBookTest: ContactsPickerBaseTest {
    override var factory: AddressBookFactory {
        get {
            return ABAddressBookFactory()
        }
    }
}

internal class ABAddressBookFactory: AddressBookFactory {
    func createAddressBook() throws -> AddressBookProtocol {
        return try ABAddressBookImpl()
    }
}
