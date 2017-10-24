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

@objc class Notification: NSObject {
    
    let serverPostAlertURL = "https://2f2e638b.ngrok.io/sms"

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
        print(contacts)
        
        //TODO: Get contacts from contacts array and post to server
        let parameters: Parameters = ["text": "test"]
        
        // Alamofire posts request to server
        Alamofire.request(serverPostAlertURL, method: .post, parameters: parameters).responseJSON(completionHandler: { response in
            let result = response.result
            print("Server result: ")
            print(result)
        })
        
        print("Text message sent to server")
    }
}



