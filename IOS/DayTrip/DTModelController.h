//
//  DTModelController.h
//  DayTrip
//
//  Created by Joe Andresen on 3/2/14.
//  Copyright (c) 2014 Joseph Andresen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DTDataViewController;

@interface DTModelController : NSObject <UIPageViewControllerDataSource>

- (DTDataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(DTDataViewController *)viewController;

@end
