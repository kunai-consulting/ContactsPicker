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
    override var factory: InternalAddressBookFactory {
        get {
            return ABInternalAddressBookFactory()
        }
    }
}

internal class ABInternalAddressBookFactory: InternalAddressBookFactory {
    func createInternalAddressBook() throws -> InternalAddressBook {
        return try ABAddressBookImpl()
    }
}
