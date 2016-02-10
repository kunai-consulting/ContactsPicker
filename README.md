# ContactsPicker
Quick and easy way to access contacts from address book on >=iOS8.
## Setup
Easiest way to install library is via cocoapods:  
`pod 'ContactsPicker'`

# API
## Basic usage
1. Import `ContactsPicker` module 
2. Request access to address book by using `requestAccessToAddressBook` method
3. Add, delete, update and find contacts 
4. Commit changes by using `commitChangesToAddressBook` method

Example:  
```
        do {
            let ab = try AddressBook()
            ab.requestAccessToAddressBook({ (access, error) -> Void in
                print("got accesss to address book!")
                let contact = AddressBookRecord()
                contact.firstName = "Me"
                contact.lastName = "Is here"
                contact.phoneNumbers = [AddressBookRecordLabel(label: nil, value: "111"), AddressBookRecordLabel(label: nil, value: "111")]
                do {
                    try ab.addContactToAddressBook(contact)
                    try ab.commitChangesToAddressBook()
                } catch {
                  // handle error 
                }
            })
        } catch {
            // handle error
        }
```
## Using query builder
For more detailed queries you can build your own `queryBuilder` and add predicate to it so only specific contacts will be fetched. 
As an example, to get contacts with long full name you can create custom predicate:
```
let predicateForLongName: ContactPredicate = { contact in
            return contact.fullName?.characters.count > 10
}
```
and then pass it to query builder, as here: 
```
let queryBuilder = self.addressBook.queryBuilder().matchingPredicate(predicateForLongName)
let contactsWithLongName = try queryBuilder.query()
```

## Supported contact properties
Currently, library supports access to those properties: 
- identifier
- first name
- middle name
- last name
- phone numbers
- email addresses
- organization name

## AddressBook API
- `requestAccessToAddressBook( completion: (Bool, NSError?) -> Void )`  
Usually that will be your first call to library. That method will ask user for letting use his contacts from phone's address book. In `completion` block you can handle his choice by checking `Bool` parameter. 
- `retrieveAddressBookRecordsCount() throws -> Int`  
Returns number of all contacts inside address book.
- `addContactToAddressBook(contact: ContactProtocol) throws -> ContactProtocol`  
Adds new contact to address book. Use `AddressBookRecord` to create object with contact's properties.
- `func updateContact(contact: ContactProtocol)`  
Updates values for existing contact. 
- `func deleteAllContacts() throws`  
Deletes all contacts from address book.
- `func deleteContactWithIdentifier(identifier: String?) throws`  
Delete contact with specified `identifier`.
- `func queryBuilder() -> AddressBookQueryBuilder`  
Creates `AddressBookQueryBuilder` used for specific contact queries. You can specify predicate and properties you want to fetch by using `matchingPredicate` and `keysToFetch` methods.
- `func findContactWithIdentifier(identifier: String?) -> ContactProtocol?`  
Returns (optional) contact with specified `identifier`.
- `func findContactsMatchingName(name: String) throws -> [ContactProtocol]`  
Returns all contacts matching `name` parameter.
- `func findAllContacts() throws -> [ContactProtocol]`  
Returns all contacts from user's address book.
- `func commitChangesToAddressBook() throws`  
You should call this method after using methods for adding, deleting or updating contacts to save those changes.
