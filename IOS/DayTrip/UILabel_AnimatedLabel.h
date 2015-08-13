//
//  UILabel_AnimatedLabel.h
//  DayTrip
//
//  Created by Joe Andresen on 3/6/14.
//  Copyright (c) 2014 Joseph Andresen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnimatedLabel : UILabel ()

-(void) startTimer: (int)time;
-(void) fadeout;
-(void) fadein;

@end
