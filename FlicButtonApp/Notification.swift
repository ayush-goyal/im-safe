//
//  Notification.swift
//  FlicButtonApp
//
//  Created by Macbook on 10/16/17.
//  Copyright © 2017 Ayush. All rights reserved.
//

import Foundation
import UserNotifications
import Alamofire
import CoreData
import CoreLocation

var alertModeOn: Bool = false

@objc class Notification: NSObject {
    
    let serverPostAlertURL = "https://5f6b896d.ngrok.io/sendAlert"    //  "https://im-safe-server.herokuapp.com/sendAlert"

    func sendNotification() {
        // Method called by objective c when button is pressed
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (settings) in
            if(settings.authorizationStatus == .authorized) {
                self.setupNotification()
            } else {
                UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .badge, .alert], completionHandler: { (granted, error) in
                    if let error = error {
                        print(error)
                    } else {
                        if (granted) {
                            self.setupNotification()
                        }
                    }
                })
            }
        })
    }
    
    func setupNotification() {
        // Notification is made and sent
        let identifier = "alert"
        let cancelAction = UNNotificationAction(identifier: "cancel", title: "Cancel Alert", options: [])
        let alarmCategory = UNNotificationCategory(identifier: "alert.category",actions: [cancelAction],intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([alarmCategory])
        
        let content = UNMutableNotificationContent()
        content.title = "ALERT: Button Pressed"
        content.subtitle = "Contacts will be alerted"
        content.body = "Swipe to cancel"
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "alert.category"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        
        let notificationRequest = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(notificationRequest) { (error) in
            if let error = error {
                print(error)
            } else {
                print("Notification scheduled")
            }
        }
    }
    
    func sendAlert() {
        // Takes all contacts in table view and makes request to server to send alert
        print("Contacts:")
        print(alertContacts)
        print("Current Location:")
        print(currentLocation)
        
        //TODO: Get contacts from contacts array and post to server
        
        var parameterInfo: [String: String] = [:]
        if let contacts = alertContacts {
            for contact in contacts {
                parameterInfo[contact.name] = contact.number
            }
            
            let parameters: Parameters = ["people": parameterInfo, "senderNumber": "6783309948", "token": FCMToken, "coordinate": ["latitude": currentLocation?.coordinate.latitude, "longitude": currentLocation?.coordinate.longitude]]
            
            // Alamofire posts request to server
            Alamofire.request(serverPostAlertURL, method: .post, parameters: parameters, encoding: JSONEncoding.default).response(completionHandler: { response in
                print("Server response: ")
                print(response.data)
            })
            
            alertModeOn = true
            print("Text message sent to server")
        }
    }
    
}
