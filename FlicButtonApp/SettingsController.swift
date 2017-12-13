//
//  SettingsController.swift
//  FlicButtonApp
//
//  Created by Macbook on 10/13/17.
//  Copyright © 2017 Ayush. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI
import CoreData

class SettingsController: UITableViewController, CNContactPickerDelegate {
    
    // MARK: - Core Data Setup
    var managedObjectContext: NSManagedObjectContext!
    lazy var fetchedResultsController: AlertContactFetchedResultsController = {
        return AlertContactFetchedResultsController(managedObjectContext: self.managedObjectContext, tableView: self.tableView)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        alertContacts = fetchedResultsController.fetchedObjects
        // Prevents empty cells from appearing at bottom of table
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    // MARK: - Table view data source

    // Tells table view number of sections from core data
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    // Tells table view number of rows(ie number of contacts) from core data
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            // Fatal error if no sections because something went wrong
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    // Create a cell from AlertContactCell for each contact
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "alertContactCell", for: indexPath) as? AlertContactCell else { fatalError() }
        
        let alertContact = fetchedResultsController.object(at: indexPath)
        
        cell.name.text = alertContact.name
        cell.number.text = alertContact.number
        
        return cell
    }
    
    // Function called when users swipes left and presses "Delete" button on contact
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            let alertContact = fetchedResultsController.object(at: indexPath)
            
            // Removes contact from core data
            managedObjectContext.delete(alertContact)
            managedObjectContext.saveChanges()
            alertContacts = fetchedResultsController.fetchedObjects
        }
    }
    
    // MARK: - Contacts
    
    // IBAction to open contact picker controller to allow user to select contacts
    @IBAction func addContacts(_ sender: Any) {
        let cnPicker = CNContactPickerViewController()
        cnPicker.delegate = self
        self.present(cnPicker, animated: true, completion: nil)
    }
    
    // Once contacts are selected from picker, they are individually added to table view through helper method
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
        // Calls function to add each selected contact to table view
        contacts.forEach { contact in
            addContact(givenName: contact.givenName, andFamilyName: contact.familyName, forNumber: contact.phoneNumbers[0].value.stringValue)
        }
    }
    
    // When user presses "Cancel" button in contact picker
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        print("Cancel Contact Picker")
    }
    
    // MARK: - Contacts Helper Methods
    
    // Adds given contact to table view
    func addContact(givenName: String, andFamilyName familyName: String, forNumber number: String) {
        
        let alertContact = NSEntityDescription.insertNewObject(forEntityName: "AlertContact", into: managedObjectContext) as! AlertContact
        alertContact.name = "\(givenName) \(familyName)"
        alertContact.number = number
        
        // Save changes to contacts to core data
        managedObjectContext.saveChanges()
        alertContacts = fetchedResultsController.fetchedObjects
        
    }
}
