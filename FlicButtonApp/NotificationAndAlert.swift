//
//  NotificationAndAlert.swift
//  FlicButtonApp
//
//  Created by Macbook on 10/16/17.
//  Copyright © 2017 Ayush. All rights reserved.
//

import Foundation
import UserNotifications
import Alamofire

@objc final class NotificationAndAlert: NSObject {

    // Constant server URL Variables
    static let serverPostAlertURL: URLConvertible = "https://5b0074ee.ngrok.io/sendAlert"
    static let serverPostCancelURL: URLConvertible = "https://5b0074ee.ngrok.io/cancelAlert"
    
    // Method called by objective c when button is pressed
    static func sendNotification() {
        
        // Checks to see if user notifications are enabled and asks for authorization if not
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (settings) in
            if(settings.authorizationStatus == .authorized) {
                // Calls method to actually create and send notification to user
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
    
    // Function creates and sets up alert notification and then sends to user
    static func setupNotification() {
        
        // Notification action and category are created and set
        let cancelAction = UNNotificationAction(identifier: "cancel", title: "Cancel Alert", options: [])
        let alarmCategory = UNNotificationCategory(identifier: "alert.category",actions: [cancelAction],intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([alarmCategory])
        
        // Notification identifier is made
        let identifier = "alert"
        
        // Notification content is made
        let content = UNMutableNotificationContent()
        content.title = "ALERT: Button Pressed"
        content.subtitle = "Contacts will be alerted"
        content.body = "Swipe to cancel"
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "alert.category"
        
        //Notification trigger is made
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        
        // Identifier, content, and trigger are combined into notification request
        let notificationRequest = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // Notification is sent to notification center to be scheduled and sent
        UNUserNotificationCenter.current().add(notificationRequest) { (error) in
            if let error = error {
                print(error)
            } else {
                print("Notification scheduled")
            }
        }
    }
    
    // Takes all contacts in table view and makes request to server to send alert to all contacts
    static func sendAlert() {
        // Print information for debugging
        print("--------------------------------------------")
        print("Sending Alert to Server with....")
        print("\nContacts:")
        print(alertContacts)
        print("\nCurrent Location:")
        print(currentLocation)
        print("--------------------------------------------")
        
        if let contacts = alertContacts {
            // Gets all information from contacts that user listed and puts in parameter variable to send to server
            var contactParameters: [String: String] = [:]
            for contact in contacts {
                contactParameters[contact.name] = contact.number
            }

            // Creates parameter variable to hold information that will be sent to server
            let parameters: Parameters? = ["people": contactParameters, "token": FCMToken, "coordinate": ["latitude": currentLocation?.coordinate.latitude, "longitude": currentLocation?.coordinate.longitude]]
            
            // Alamofire posts request to server to send alert
            Alamofire.request(serverPostAlertURL, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseString { response in
                print("Server responded with....")
                print("\nSuccess: \(response.result.isSuccess)")
                print("\nResponse String: \(response.result.value)")
                print("--------------------------------------------")
            }
            
            // Turn alert mode on now that message has been sent to server
            alertModeOn = true
        }
    }
    
    // Takes all contacts in table view and makes request to server to send cancel alert once alert is over
    static func cancelAlert() {
        print("--------------------------------------------")
        print("Sending Cancel Alert to Server with....")
        print("\nContacts:")
        print(alertContacts)
        print("--------------------------------------------")
        
        if let contacts = alertContacts {
            // Gets all information from contacts that user listed and puts in parameter variable to send to server
            var parameterInfo: [String: String] = [:]
            for contact in contacts {
                parameterInfo[contact.name] = contact.number
            }
            
            // Creates parameter variable to hold information that will be sent to server
            let parameters: Parameters = ["people": parameterInfo]
            
            // Alamofire posts request to server with parameter info
            Alamofire.request(serverPostCancelURL, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseString { response in
                print("Server responded with....")
                print("\nSuccess: \(response.result.isSuccess)")
                print("\nResponse String: \(response.result.value)")
                print("--------------------------------------------")
            }
            
            // Once alert has been cancelled, alert mode is turned off
            alertModeOn = false
        }
    }
    
}
