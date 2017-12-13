//
//  ViewController.h
//  FlicButtonApp
//
//  Created by Macbook on 9/14/17.
//  Copyright © 2017 Ayush. All rights reserved.
//

#import <fliclib/fliclib.h>
#import <UserNotifications/UserNotifications.h>

@interface HomeViewController : UIViewController <SCLFlicManagerDelegate, SCLFlicButtonDelegate, UNUserNotificationCenterDelegate> {
    
}

// Button and label references for screen that can be changed
@property (strong, nonatomic) IBOutlet UILabel *buttonStatusLabel;
@property (strong, nonatomic) IBOutlet UILabel *appStatusLabel;
@property (strong, nonatomic) IBOutlet UIButton *flicConnectButton;
@property (strong, nonatomic) IBOutlet UIButton *disableOrEnableAppButton;

@end



