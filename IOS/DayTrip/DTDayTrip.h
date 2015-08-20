//
//  DTDayTrip.h
//  DayTrip
//
//  Created by Joe Andresen on 1/10/15.
//  Copyright (c) 2015 Joseph Andresen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MapKit/Mapkit.h"
#import "DTPOI.h"

@class DTPOI;

@protocol DayTripModelDelegate <NSObject>

- (void) modelUpdated;

@end

@interface DTDayTrip : NSObject

@property (nonatomic, weak) id<DayTripModelDelegate> delegate;

- (NSArray*) filteredLocations;
- (void) addPOI:(DTPOI*)poi;

- (void) import;
- (void) persist:(DTPOI*)poi;

- (void) runQuery:(NSString*)queryString;
- (void) queryRegion:(MKCoordinateRegion)region;

@end

