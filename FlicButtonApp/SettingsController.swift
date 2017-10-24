//
//  SettingsController.swift
//  FlicButtonApp
//
//  Created by Macbook on 10/13/17.
//  Copyright © 2017 Ayush. All rights reserved.
//

import UIKit
import Alamofire
import Contacts
import ContactsUI
import UserNotifications

var contacts: [[String]] = []

class SettingsController: UITableViewController, CNContactPickerDelegate {
    
    var containerView: UIView!
    var section = "1"
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(sendTwilio), name: NSNotification.Name(rawValue: "sendTextWithTwilio"), object: nil)
    
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath)
        
        cell.textLabel?.text = contacts[indexPath.row][0]
        cell.detailTextLabel?.text = contacts[indexPath.row][1]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            contacts.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
    
    // MARK: - Contacts
    
    @IBAction func selectContacts() {
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
        contacts.append(["\(givenName) \(familyName)", number])
        
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath(row: contacts.count - 1, section: 0)], with: .automatic)
        tableView.endUpdates()
    }
    
    func sendTwilio() {
        // Takes all contacts in table view and makes request to server to send alert
        print("Text message sent!")
        print(contacts)
        
        let parameters: Parameters = ["hello": "hello"]
        
        Alamofire.request("https://2f2e638b.ngrok.io/sms", method: .post, parameters: parameters).responseJSON(completionHandler: { response in
            let result = response.result
            print(result)
        })
    }
}
