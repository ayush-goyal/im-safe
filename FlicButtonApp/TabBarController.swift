//
//  TabBarController.swift
//  FlicButtonApp
//
//  Created by Macbook on 11/8/17.
//  Copyright © 2017 Ayush. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class TabBarController: UITabBarController {
    
    let coreDataStack = CoreDataStack()
    lazy var managedObjectContext: NSManagedObjectContext = {
        self.coreDataStack.managedObjectContext
    }()
    
    var alertView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))

    override func viewDidLoad() {
        super.viewDidLoad()

        if let tabBarViewControllers = self.viewControllers {
            if let navigationController = tabBarViewControllers[1] as? UINavigationController, let settingsController = navigationController.topViewController as? SettingsController {
                settingsController.managedObjectContext = self.managedObjectContext
            }
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("added to view")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(alertModeOn)
        if alertModeOn {
            alertView.translatesAutoresizingMaskIntoConstraints = false
            alertView.backgroundColor = UIColor.red
            
            let titleLabel = UILabel(frame: CGRect.zero)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.text = "Alert Was Triggered"
            titleLabel.textColor = UIColor.white
            titleLabel.font = UIFont.systemFont(ofSize: 25, weight: UIFontWeightHeavy)
            
            let cancelButton = UIButton(frame: CGRect.zero)
            cancelButton.translatesAutoresizingMaskIntoConstraints = false
            cancelButton.setTitle("Cancel Alert", for: .normal)
            cancelButton.titleLabel?.textColor = UIColor.white
            cancelButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 19)
            cancelButton.addTarget(self, action: #selector(cancelAlert), for: .touchUpInside)
            
            view.addSubview(titleLabel)
            titleLabel.centerXAnchor.constraint(equalTo: alertView.centerXAnchor).isActive = true
            titleLabel.centerYAnchor.constraint(equalTo: alertView.topAnchor, constant: 180).isActive = true
            
            view.addSubview(cancelButton)
            cancelButton.centerXAnchor.constraint(equalTo: alertView.centerXAnchor).isActive = true
            cancelButton.centerYAnchor.constraint(equalTo: alertView.centerYAnchor).isActive = true
            
            self.view.addSubview(alertView)
            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        }
    }
    
    func addAlertView() {
        print("Alert View")
        print(alertModeOn)
        if alertModeOn == true {
            alertView.translatesAutoresizingMaskIntoConstraints = false
            alertView.backgroundColor = UIColor.red
            
            let titleLabel = UILabel(frame: CGRect.zero)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.text = "Alert Was Triggered"
            titleLabel.textColor = UIColor.white
            titleLabel.font = UIFont.systemFont(ofSize: 25, weight: UIFontWeightHeavy)
            
            let cancelButton = UIButton(frame: CGRect.zero)
            cancelButton.translatesAutoresizingMaskIntoConstraints = false
            cancelButton.setTitle("Cancel Alert", for: .normal)
            cancelButton.titleLabel?.textColor = UIColor.white
            cancelButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 19)
            cancelButton.addTarget(self, action: #selector(cancelAlert), for: .touchUpInside)
            
            alertView.addSubview(titleLabel)
            titleLabel.centerXAnchor.constraint(equalTo: alertView.centerXAnchor).isActive = true
            titleLabel.centerYAnchor.constraint(equalTo: alertView.topAnchor, constant: 180).isActive = true
            
            alertView.addSubview(cancelButton)
            cancelButton.centerXAnchor.constraint(equalTo: alertView.centerXAnchor).isActive = true
            cancelButton.centerYAnchor.constraint(equalTo: alertView.centerYAnchor).isActive = true
            
            self.view.addSubview(alertView)
            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cancelAlert() {
        let serverPostCancelURL = "https://im-safe-server.herokuapp.com/cancelAlert"
        // Takes all contacts in table view and makes request to server to send alert
        print("Contacts:")
        print(alertContacts)
        
        //TODO: Get contacts from contacts array and post to server
        
        var parameterInfo: [String: String] = [:]
        if let contacts = alertContacts {
            for contact in contacts {
                parameterInfo[contact.name] = contact.number
            }
            
            let parameters: Parameters = ["people": parameterInfo, "senderNumber": "6783309948"]
            
            // Alamofire posts request to server
            Alamofire.request(serverPostCancelURL, method: .post, parameters: parameters, encoding: JSONEncoding.default).response(completionHandler: { response in
                print("Server response: ")
                print(response.response)
            })
            
            alertModeOn = false
            print("Cancel Alert Sent to Server")
            self.view.willRemoveSubview(alertView)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
