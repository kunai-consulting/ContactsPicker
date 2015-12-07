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
    override var factory: AddressBookFactory {
        get {
            return CNAddressBookFactory()
        }
    }
}

internal class CNAddressBookFactory: AddressBookFactory {
    func createAddressBook() -> AddressBookProtocol {
         return CNAddressBookImpl()
    }
}