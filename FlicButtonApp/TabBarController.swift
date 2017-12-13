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
import CoreLocation

var currentLocation: CLLocation?
var alertContacts: [AlertContact]?

class TabBarController: UITabBarController, CLLocationManagerDelegate {
    
    // Init Core Data to persist emergency contact information between app sessions
    let coreDataStack = CoreDataStack()
    lazy var managedObjectContext: NSManagedObjectContext = {
        self.coreDataStack.managedObjectContext
    }()
    
    // Init location manager for user location
    let locationManager = CLLocationManager()
    
    // Create views for alert view
    lazy var alertView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.red
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Alert Was Triggered"
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 25, weight: UIFontWeightHeavy)
        return label
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Cancel Alert", for: .normal)
        button.titleLabel?.textColor = UIColor.white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 19)
        button.addTarget(self, action: #selector(cancelAlert), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let tabBarViewControllers = self.viewControllers {
            if let navigationController = tabBarViewControllers[1] as? UINavigationController, let settingsController = navigationController.topViewController as? SettingsController {
                settingsController.managedObjectContext = self.managedObjectContext
                _ = settingsController.view
            }
        }
        
        locationManager.delegate = self
        enableLocationServices()
    }
    
    func addAlertView(window: UIWindow?) {
        if alertModeOn == true {

            alertView.addSubview(titleLabel)
            titleLabel.centerXAnchor.constraint(equalTo: alertView.centerXAnchor).isActive = true
            titleLabel.centerYAnchor.constraint(equalTo: alertView.topAnchor, constant: 180).isActive = true
            
            alertView.addSubview(cancelButton)
            cancelButton.centerXAnchor.constraint(equalTo: alertView.centerXAnchor).isActive = true
            cancelButton.centerYAnchor.constraint(equalTo: alertView.centerYAnchor).isActive = true
            
            view.window!.addSubview(alertView)
            alertView.leadingAnchor.constraint(equalTo: window!.leadingAnchor).isActive = true
            alertView.trailingAnchor.constraint(equalTo: window!.trailingAnchor).isActive = true
            alertView.topAnchor.constraint(equalTo: window!.topAnchor).isActive = true
            alertView.bottomAnchor.constraint(equalTo: window!.bottomAnchor).isActive = true
        }
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
            alertView.removeFromSuperview()
        }
    }
    
    //MARK: - CoreLocation
    
    func enableLocationServices() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            break
        case .restricted, .denied:
            //TODO: send alert to turn on notification or app wont work
            break
        case .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()
            //TODO: send alert to turn on always or app wont work
            break
        case .authorizedAlways:
            startReceivingLocationChanges()
        }
    }
    
    func startReceivingLocationChanges() {
        if CLLocationManager.authorizationStatus() == .authorizedAlways && CLLocationManager.locationServicesEnabled() == true {
            print("Turning on location services to receive location")
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = 50.0
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("Authorization status of location services changed")
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            break
        case .restricted, .denied:
            //TODO: send alert to turn on notification or app wont work
            break
        case .authorizedWhenInUse:
            //TODO: send alert to turn on always or app wont work
            break
        case .authorizedAlways:
            startReceivingLocationChanges()
        }
    }
}
