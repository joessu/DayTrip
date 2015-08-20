//
//  DTRootViewController.h
//  DayTrip
//
//  Created by Joe Andresen on 3/2/14.
//  Copyright (c) 2014 Joseph Andresen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DTRootViewController : UIViewController <UIPageViewControllerDelegate, NSURLSessionDelegate>

typedef NS_ENUM(NSUInteger, DayTripProtocol) {
    registerRequest = 0,
    loginRequest = 1,
    getDayTrips = 2,
    putDayTrip = 3,
    getDayTripDetailed = 4,
    ProtocolUnknown = NSUIntegerMax
};

- (NSString *)typeDisplayName;

@property (nonatomic) DayTripProtocol type;
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextBox;
@property (weak, nonatomic) IBOutlet UITextField *loginName;
@property (weak, nonatomic) IBOutlet UILabel *flavorTextLabel;
@property (strong, nonatomic) UIStoryboardSegue *LoginSegue;

- (IBAction)dismissKeyboard:(id)sender;
- (IBAction)clearTextAndSetAsSecure:(id)sender;
- (void)fadeFlavorText;
- (void)newFlavorText;
- (void)checkLoginCredentials;

-(IBAction)loginRequest:(id)sender;
-(void)setConnectionData:(NSMutableData*)connData;
-(void)httpsLogin:(NSURL*)link data:(NSData*)data;

@end
