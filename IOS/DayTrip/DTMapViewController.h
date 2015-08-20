//
//  DTMapViewController.h
//  DayTrip
//
//  Created by Joe Andresen on 1/10/15.
//  Copyright (c) 2015 Joseph Andresen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface DTMapViewController : UIViewController<MKMapViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;

- (IBAction)updateFilter:(id)sender;

@property (nonatomic) bool updateUserLocationFlag;

@end
