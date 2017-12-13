//
//  ViewController.m
//  FlicButtonApp
//
//  Created by Macbook on 9/14/17.
//  Copyright © 2017 Ayush. All rights reserved.
//

#import "HomeViewController.h"
#import "FlicButtonApp-Swift.h"

@interface HomeViewController ()
    
@end

static NSTimeInterval timeWait;
static int timeToWaitAfterSetup = 2;
static float timeIntervalToCancelNotification = 8.0;
NSTimer *timer = nil;

@implementation HomeViewController

@synthesize buttonStatusLabel;
@synthesize appStatusLabel;
@synthesize flicConnectButton;
@synthesize disableOrEnableAppButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //TODO: Make app keys secret
    NSString *FLIC_APP_ID = @"2125f7c3-0d0e-42d5-88fe-fda8765867d6";
    NSString *FLIC_APP_SECRET = @"94d6448c-22d3-4d2e-951f-f625f60f471a";
    
    //Setup initial Flic Manager
    [SCLFlicManager configureWithDelegate:self defaultButtonDelegate:self appID:FLIC_APP_ID appSecret:FLIC_APP_SECRET backgroundExecution:YES];
    
    //Setup initial condition for button
    self.disableOrEnableAppButton.enabled = NO;
    
    //Get notification authorization and set delegate
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if(!error) {
            NSLog(@"Notification authorization successful");
        } else {
            NSLog(@"Notification authorization failed:");
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}
    
//MARK: Helper Methods
    
- (void)sendNotification:(NSString*)title message:(NSString*)message actions:(NSArray*)actions {
    //Helper method to show notification to user with passed in title, message, and alert(s)
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:title
                                 message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    for (NSString *actionTitle in actions) {
        UIAlertAction* button = [UIAlertAction
                                   actionWithTitle:actionTitle
                                   style:UIAlertActionStyleDefault
                                   handler:nil];
        [alert addAction:button];
    }
    [self presentViewController:alert animated:YES completion:nil];
}
    
-(void)sendAlert {
    // When button is pressed and timer expires, send alert
    NSLog(@"Alert sent from objective c");
    timer = nil;
    [NotificationAndAlert sendAlert];
}
    
//MARK: Flic Delegate Methods
    
- (void) flicManager:(SCLFlicManager *)manager didDiscoverButton:(SCLFlicButton *)button withRSSI:(NSNumber *)RSSI; {
    //New button has been discovered
    NSLog(@"New button discovered");
    [[SCLFlicManager sharedManager] stopScan];
    [button connect];
}
    
- (void) flicButtonDidConnect:(SCLFlicButton *)button {
    // Button has been connected
    NSLog(@"Button conencted");
}

- (void) flicButtonIsReady:(SCLFlicButton *)button {
    // Button has been verified and is ready to use - Set user interface
    NSLog(@"Button is ready");
    self.buttonStatusLabel.text = @"Connected";
    self.buttonStatusLabel.textColor = [UIColor greenColor];
    self.flicConnectButton.enabled = NO;
    self.appStatusLabel.text = @"Enabled";
    self.appStatusLabel.textColor = [UIColor greenColor];
    [self.disableOrEnableAppButton setTitle:@"Press to Disable" forState:UIControlStateNormal];
    self.disableOrEnableAppButton.enabled = YES;
    
    //Variable to make sure that button isn't accidently triggered when first setting up
    timeWait = [[NSDate date] timeIntervalSince1970];
}

- (void) flicButton:(SCLFlicButton *)button didDisconnectWithError:(NSError *)error {
    // Button has been disconnected - Set user interface
    NSLog(@"Button disconnected");
    self.buttonStatusLabel.text = @"Disconnected";
    self.buttonStatusLabel.textColor = [UIColor redColor];
    self.flicConnectButton.enabled = YES;
    self.appStatusLabel.text = @"Disabled";
    self.appStatusLabel.textColor = [UIColor redColor];
    [self.disableOrEnableAppButton setTitle:@"Press to Enable" forState:UIControlStateNormal];
    self.disableOrEnableAppButton.enabled = NO;
}

- (void) flicButton:(SCLFlicButton *)button didReceiveButtonClick:(BOOL)queued age:(NSInteger)age {
    // Button was clicked
    NSLog(@"Button clicked");
    
    self.buttonStatusLabel.text = @"Connected";
    self.buttonStatusLabel.textColor = [UIColor greenColor];
    self.flicConnectButton.enabled = NO;
    self.appStatusLabel.text = @"Enabled";
    self.appStatusLabel.textColor = [UIColor greenColor];
    [self.disableOrEnableAppButton setTitle:@"Press to Disable" forState:UIControlStateNormal];
    self.disableOrEnableAppButton.enabled = YES;
    
    //If app is enabled and enough time has passed once button is setup, send notification
    if ([self.appStatusLabel.text isEqualToString:@"Enabled"] && [[NSDate date] timeIntervalSince1970] > (timeWait + timeToWaitAfterSetup) && timer == nil) {
        // Make sure timer still works in background
        UIBackgroundTaskIdentifier bgTask = 0;
        UIApplication *app = [UIApplication sharedApplication];
        bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
            [app endBackgroundTask:bgTask];
        }];
        
        //Gives user certain amount of time to cancel notification before alert is sent
        timer = [NSTimer scheduledTimerWithTimeInterval:timeIntervalToCancelNotification target:self selector:@selector(sendAlert) userInfo:nil repeats:NO];
        [NotificationAndAlert sendNotification];

    }
}

- (void)flicManagerDidRestoreState:(SCLFlicManager *_Nonnull)manager {
    NSLog(@"Flic Manager state restored");
}

//MARK: Notification Center Delegate Methods

- (void) userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    // Shows notification even though app is in foreground
    NSLog(@"App in foreground");
    completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionSound);
}
    
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    // When notification "cancel" button is pressed, cancel timer that would send alert
    NSLog(@"receive response");
    if([response.notification.request.content.categoryIdentifier isEqualToString:@"alert.category"]) {
        if([response.actionIdentifier isEqualToString:@"cancel"]) {
            NSLog(@"Cancelled from objective c & timer invalidated");
            [timer invalidate];
            timer = nil;
        }
    }
    completionHandler();
}
    
//MARK: Interface Builder actions
    
- (IBAction)startScanAction:(id)sender {
    //Check to see if user has bluetooth turned on
    if ([SCLFlicManager sharedManager].bluetoothState != SCLFlicManagerBluetoothStatePoweredOn) {
        [self sendNotification:@"Turn on bluetooth" message:@"Please turn on bluetooth so the app can connect with the physical button" actions:[NSArray arrayWithObject:@"Ok"]];
    }
    
    //Check to see if any buttons known
    if ([SCLFlicManager sharedManager].knownButtons.count == 0) {
        NSLog(@"No known buttons");
    } else {
        //If buttons are known, try connecting to all known buttons first before scanning
        NSDictionary *knownButtons = [[SCLFlicManager sharedManager] knownButtons];
        for(NSString *key in [knownButtons allKeys]) {
            NSLog(@"Button Key:%@ ButtonObject:%@", key, [knownButtons objectForKey:key]);
            [[knownButtons objectForKey:key] connect];
        }
    }
    
    //Start scan for buttons
    NSLog(@"Button scan started");
    [[SCLFlicManager sharedManager] startScan];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"Button scan stopped");
        [[SCLFlicManager sharedManager] stopScan];
    });
}

- (IBAction)simulateButonPress:(id)sender {
    //IBAction to simulate button press without physical button
    //If app is enabled and enough time has passed once button is setup, send notification
    if (timer == nil) {
        // Make sure timer still works in background
        UIBackgroundTaskIdentifier bgTask = 0;
        UIApplication *app = [UIApplication sharedApplication];
        bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
            [app endBackgroundTask:bgTask];
        }];
        
        //Gives user certain amount of time to cancel notification before alert is sent
        timer = [NSTimer scheduledTimerWithTimeInterval:timeIntervalToCancelNotification target:self selector:@selector(sendAlert) userInfo:nil repeats:NO];
        [NotificationAndAlert sendNotification];

    }
}
    
- (IBAction)enableOrDisableAppButton:(id)sender {
    //IBAction to enable/disable app when button pressed
    UIButton *button = (UIButton *)sender;
    if ([button.currentTitle isEqualToString:@"Press to Disable"]) {
        [sender setTitle:@"Press to Enable" forState:UIControlStateNormal];
        self.appStatusLabel.text = @"Disabled";
        self.appStatusLabel.textColor = [UIColor redColor];
    } else {
        [sender setTitle:@"Press to Disable" forState:UIControlStateNormal];
        self.appStatusLabel.text = @"Enabled";
        self.appStatusLabel.textColor = [UIColor greenColor];
    }
}

@end
