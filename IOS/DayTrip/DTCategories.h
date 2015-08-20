//
//  DTCategories.h
//  DayTrip
//
//  Created by Joe Andresen on 1/10/15.
//  Copyright (c) 2015 Joseph Andresen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DTCategories : NSObject

+ (NSArray*) allCategories;
+ (NSArray*) activeCategories;

+ (NSArray*) filteredCategories;
+ (void) setFilteredCategories:(NSArray*)categories;

+ (BOOL) filterOnFor:(NSString*)category;
+ (void) setFilter:(NSString*)category on:(BOOL)on;

+ (NSString*) query;

@end
