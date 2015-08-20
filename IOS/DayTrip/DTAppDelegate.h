//
//  DTAppDelegate.h
//  DayTrip
//
//  Created by Joe Andresen on 3/2/14.
//  Copyright (c) 2014 Joseph Andresen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTDayTrip.h"

@interface DTAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

/** Singleton data model */
@property (strong, nonatomic) DTDayTrip* daytrip;

/** Helper to get static instance */
+ (DTAppDelegate*) appDelegate;


@end
