//
//  DTCategories.m
//  DayTrip
//
//  Created by Joe Andresen on 1/10/15.
//  Copyright (c) 2015 Joseph Andresen. All rights reserved.
//

#import "DTCategories.h"
#import "DTAppDelegate.h"

@implementation DTCategories 

static NSMutableDictionary* categoryMeta;

+ (void)initialize
{
    categoryMeta = [NSMutableDictionary dictionary];
}

+ (NSArray*) allCategories
{
    static NSArray* defaultCategories;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultCategories = @[
                              @"Park",
                              @"Museum",
                              @"Battlefield",
                              @"Lunch Spot"
                              ];
    });
    
    NSMutableSet* maxCategories = [NSMutableSet setWithArray:defaultCategories];
    [maxCategories addObjectsFromArray:[self activeCategories]];
    return [maxCategories allObjects];

}

+ (NSArray*) activeCategories
{
    //TODO: Fix this.
    NSArray* locations = [[DTAppDelegate appDelegate].daytrip filteredLocations];
    NSArray* a = [locations valueForKeyPath:@"categories"];
    NSMutableSet* categorySet = [NSMutableSet set];
    for (NSArray* categories in a) {
        [categorySet addObjectsFromArray:categories];
    }
    return [categorySet allObjects];
}

+ (NSArray*) filteredCategories:(BOOL) quote
{
    NSMutableArray* a = [NSMutableArray array];
    [categoryMeta enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj boolValue]) {
            if (quote) {
                [a addObject:[NSString stringWithFormat:@"\"%@\"", key]];
            } else {
                [a addObject:key];
            }
        }
    }];
    return a;
}

+ (void) setFilteredCategories:(NSArray*)categories
{
    [categoryMeta removeAllObjects];
    for (NSString* key in categories) {
        categoryMeta[key] = @(YES);
    }
}

+ (NSArray*) filteredCategories
{
    return [self filteredCategories:NO];
}

+ (BOOL) filterOnFor:(NSString*)category
{
    return [categoryMeta[category] boolValue];
}

+ (void) setFilter:(NSString*)category on:(BOOL)on
{
    categoryMeta[category] = @(on);
}

+ (NSString*) query
{
    NSArray* a = [self filteredCategories:YES]; //1
    NSString* query = @"";
    if (a.count > 0) {
        
        query = [NSString stringWithFormat:@"{\"categories\":{\"$in\":[%@]}}", [a componentsJoinedByString:@","]]; //2
        query = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                      (CFStringRef) query,
                                                                                      NULL,
                                                                                      (CFStringRef) @"!*();':@&=+$,/?%#[]{}",
                                                                                      kCFStringEncodingUTF8));
        
        query = [@"?query=" stringByAppendingString:query];
    }
    return query;
}

@end
