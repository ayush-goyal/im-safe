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
    
    var managedObjectContext: NSManagedObjectContext!
    lazy var fetchedResultsController: AlertContactFetchedResultsController = {
        return AlertContactFetchedResultsController(managedObjectContext: self.managedObjectContext, tableView: self.tableView)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Prevents empty cells from appearing at bottom of table
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "alertContactCell", for: indexPath) as? AlertContactCell else { fatalError() }
        
        let alertContact = fetchedResultsController.object(at: indexPath)
        
        cell.name.text = alertContact.name
        cell.number.text = alertContact.number
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            let alertContact = fetchedResultsController.object(at: indexPath)
            
            managedObjectContext.delete(alertContact)
            managedObjectContext.saveChanges()
        }
    }
    
    // MARK: - Contacts
    
    @IBAction func addContacts(_ sender: Any) {
        // IBAction to open contact picker controller to allow user to select contacts
        let cnPicker = CNContactPickerViewController()
        cnPicker.delegate = self
        self.present(cnPicker, animated: true, completion: nil)
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
        // Calls function to add each selected contact to table view
        contacts.forEach { contact in
            addContact(givenName: contact.givenName, andFamilyName: contact.familyName, forNumber: contact.phoneNumbers[0].value.stringValue)
        }
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        print("Cancel Contact Picker")
    }
    
    // MARK: - Contacts Helper Methods
    
    func addContact(givenName: String, andFamilyName familyName: String, forNumber number: String) {
        // Adds given contact to table view
        
        
        let alertContact = NSEntityDescription.insertNewObject(forEntityName: "AlertContact", into: managedObjectContext) as! AlertContact
        alertContact.name = "\(givenName) \(familyName)"
        alertContact.number = number
        
        managedObjectContext.saveChanges()
        
    }
}
