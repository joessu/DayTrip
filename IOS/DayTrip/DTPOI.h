//
//  DTPOI.h
//  DayTrip
//
//  Created by Joe Andresen on 1/10/15.
//  Copyright (c) 2015 Joseph Andresen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface DTPOI : NSObject <MKAnnotation>
@property (nonatomic, copy) NSString* _id;
@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* placeName;
@property (nonatomic, copy) NSString* details;
@property (nonatomic, retain, readonly) NSMutableArray* categories;

//allows pin to be dragged around.
@property (nonatomic) BOOL configuredBySystem;

@property (nonatomic, strong) UIImage* image;
@property (nonatomic, copy) NSString* imageId;

#pragma mark - JSON-ification

- (instancetype) initWithDictionary:(NSDictionary*)dictionary;
- (NSDictionary*) toDictionary;

#pragma mark - POI

- (void) setLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude;
- (void) setGeoJSON:(id)geoPoint;
- (void) setCoordinate:(CLLocationCoordinate2D)newCoordinate;
@end
