//
//  ViewController.swift
//  ContactsPickerTestApp
//
//  Created by Piotr on 01/12/15.
//  Copyright © 2015 kunai. All rights reserved.
//

import UIKit
import ContactsPicker

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            let ab = try AddressBook()
            ab.requestAccessToAddressBook({ (access, error) -> Void in
                print("accesss")
                let contact = AddressBookRecord()
                contact.firstName = "Me"
                contact.lastName = "Is here"
                contact.phoneNumbers = [AddressBookRecordLabel(label: nil, value: "111"), AddressBookRecordLabel(label: nil, value: "111")]
                do {
                    try ab.addContactToAddressBook(contact)
                    try ab.commitChangesToAddressBook()
                } catch {
                    
                }
            })
        } catch {
            
        }
        
        
      

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

