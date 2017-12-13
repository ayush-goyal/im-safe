//
//  TabBarController.swift
//  FlicButtonApp
//
//  Created by Macbook on 11/8/17.
//  Copyright © 2017 Ayush. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

// Global Variables
var currentLocation: CLLocation?
var alertContacts: [AlertContact]?
var alertModeOn: Bool = false

class TabBarController: UITabBarController {
    
    // Init Core Data to persist emergency contact information between app sessions
    let coreDataStack = CoreDataStack()
    lazy var managedObjectContext: NSManagedObjectContext = {
        self.coreDataStack.managedObjectContext
    }()
    
    // Init location manager for user location
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let tabBarViewControllers = self.viewControllers {
            // Gets view controllers that are associated with the tab bar controller
            if let navigationController = tabBarViewControllers[1] as? UINavigationController, let settingsController = navigationController.topViewController as? SettingsController {
                // Sets the managed object context to settings controller as to maintain the same reference
                settingsController.managedObjectContext = self.managedObjectContext
                // Initializes the settings controller view so alert contacts will not be empty
                _ = settingsController.view
            }
        }
        
        // Sets location manager delegate to self and starts location service init process
        locationManager.delegate = self
        checkLocationServicesAuthorization()
    }
    
    // MARK: - Alert View
    
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
        button.addTarget(self, action: #selector(removeAlertView), for: .touchUpInside)
        return button
    }()
    
    func addAlertView() {
        if alertModeOn == true {

            alertView.addSubview(titleLabel)
            titleLabel.centerXAnchor.constraint(equalTo: alertView.centerXAnchor).isActive = true
            titleLabel.centerYAnchor.constraint(equalTo: alertView.topAnchor, constant: 180).isActive = true
            
            alertView.addSubview(cancelButton)
            cancelButton.centerXAnchor.constraint(equalTo: alertView.centerXAnchor).isActive = true
            cancelButton.centerYAnchor.constraint(equalTo: alertView.centerYAnchor).isActive = true
            
            view.window!.addSubview(alertView)
            alertView.leadingAnchor.constraint(equalTo: view.window!.leadingAnchor).isActive = true
            alertView.trailingAnchor.constraint(equalTo: view.window!.trailingAnchor).isActive = true
            alertView.topAnchor.constraint(equalTo: view.window!.topAnchor).isActive = true
            alertView.bottomAnchor.constraint(equalTo: view.window!.bottomAnchor).isActive = true
        }
    }
    
    func removeAlertView() {
        alertView.removeFromSuperview()
        NotificationAndAlert.cancelAlert()
    }
}


extension TabBarController: CLLocationManagerDelegate {
    
    //MARK: - CoreLocation
    
    // Checks level of authorization status for location services and proceeds in correct path
    func checkLocationServicesAuthorization() {
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
            enableLocationServices()
        }
    }
    
    // Turns on location when authorization status is authorized always and location services is enabled
    func enableLocationServices() {
        if CLLocationManager.authorizationStatus() == .authorizedAlways && CLLocationManager.locationServicesEnabled() == true {
            print("Turning on location services to receive location")
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = 50.0
            locationManager.startUpdatingLocation()
        }
    }
    
    // When location changes, update current location global variable with new location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }
    
    // When location fails, print error
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    // When authorization status changes, call function again
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("Authorization status of location services changed")
        checkLocationServicesAuthorization()
    }
}
