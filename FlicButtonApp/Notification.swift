//
//  Notification.swift
//  FlicButtonApp
//
//  Created by Macbook on 10/16/17.
//  Copyright © 2017 Ayush. All rights reserved.
//

import Foundation
import UserNotifications


@objc class Notification: NSObject {
    
    var timer: Timer?
    
    func sendNotification() {
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (settings) in
            if(settings.authorizationStatus == .authorized) {
                self.scheduleNotification()
            } else {
                UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .badge, .alert], completionHandler: { (granted, error) in
                    if let error = error {
                        print(error)
                    } else {
                        if (granted) {
                            self.scheduleNotification()
                        }
                    }
                })
            }
        })
    }
    
    func scheduleNotification() {
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
        print("Alert sent")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sendTextWithTwilio"), object: nil)
        

    }
    
    
}

















