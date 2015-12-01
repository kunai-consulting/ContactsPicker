//
//  CNAddressBookTest.swift
//  ContactsPicker
//
//  Created by Piotr on 01/12/15.
//  Copyright © 2015 kunai. All rights reserved.
//

import Foundation
@testable import ContactsPicker

public class CNAddressBookTest: ContactsPickerBaseTest {
    override var factory: InternalAddressBookFactory {
        get {
            return CNInternalAddressBookFactory()
        }
    }
}

internal class CNInternalAddressBookFactory: InternalAddressBookFactory {
    func createInternalAddressBook() -> InternalAddressBook {
         return CNAddressBookImpl()
    }
}