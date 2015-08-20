//
//  FilterListViewController.h
//  TourMyTown
//
//  Created by Michael Katz on 10/10/13.
//  Copyright (c) 2013 mikekatz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DTCategoryDelegate <NSObject>

- (void) selectedCategories:(NSArray*)array;

@end

@interface FilterListViewController : UITableViewController
@property (nonatomic, weak) id<DTCategoryDelegate> delegate;

- (instancetype) initWithSelectedCategories:(NSArray*)selections deleagte:(id<DTCategoryDelegate>)delegate;

@end
