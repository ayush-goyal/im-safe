//
//  ButtonScannerUsage.m
//
//  Created by Anton Meier on 2016-04-20.
//

#import "ButtonScannerUsage.h"
#import "ButtonScanner.h"

@implementation ButtonScannerUsage

- (IBAction)startScanFlowAction:(id)sender {
    
    void (^stateChange) (SCLButtonScannerStatusEvent event, NSError *error) = ^(SCLButtonScannerStatusEvent event, NSError *error) {
        
        switch (event) {
            case SCLButtonScannerStatusEventButtonDiscovered:
                NSLog(@"ButtonScanner event: ButtonDiscovered, error: %@", error);
                // TODO: Show UI that lets the user know that a button has been discovered...
                break;
            case SCLButtonScannerStatusEventButtonConnected:
                NSLog(@"ButtonScanner event: ButtonConnected, error: %@", error);
                // TODO: Show UI that lets the user know that the button is now bluetooth connected...
                break;
            case SCLButtonScannerStatusEventButtonVerified:
                NSLog(@"ButtonScanner event: ButtonVerified, error: %@", error);
                // TODO: Show UI that lets the user know that button has been verified...
                break;
            case SCLButtonScannerStatusEventButtonVerificationFailed:
                NSLog(@"ButtonScanner event: ButtonVerificationFailed, error: %@", error);
                // TODO: Show UI that lets the user know that the button could not be verified...
                break;
            case SCLButtonScannerStatusEventButtonPrivateButtonsAvailable:
                NSLog(@"ButtonScanner event: ButtonPrivateButtonsAvailable, error: %@", error);
                // TODO: Show UI that lets the user know that there are private buttons available and that he/she has
                //       to press and hold the button for 7 seconds in order to switch it to public mode.
                break;
            default:
                break;
        }
        
    };
    
    void (^completion) (SCLFlicButton *flicButton, NSError *error) = ^(SCLFlicButton *flicButton, NSError *error) {
        
        NSLog(@"ButtonScanner Completion: %@, error: %@", flicButton, error);
        // TODO: Do something with the newly discovered and unlocked button...
        
    };
    
    ButtonScanner *scanner = [ButtonScanner sharedScanner];
    
    scanner.stateChangeHandler = stateChange;
    scanner.completionHandler = completion;
    
    [scanner startScanFlow];
    
}

- (IBAction)stopScanFlowAction:(id)sender {
    [[ButtonScanner sharedScanner] stopScanFlow];
}

@end
