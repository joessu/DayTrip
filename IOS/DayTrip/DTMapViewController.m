//
//  DTMapViewController.m
//  DayTrip
//
//  Created by Joe Andresen on 1/10/15.
//  Copyright (c) 2015 Joseph Andresen. All rights reserved.
//

#import "DTMapViewController.h"

#import "MBProgressHUD.h"

#import "DTDayTrip.h"
#import "DTPOI.h"
#import "DTCategories.h"

#import "DTAppDelegate.h"
#import "TagDetailControllerViewController.h"
#import "FilterListViewController.h"

#define kDetailSegue @"tagdetail"

@interface DTMapViewController () <UIAlertViewDelegate, DayTripModelDelegate, DTCategoryDelegate>
@property (nonatomic) BOOL waitingForLocation;
@property (nonatomic, retain) DTPOI* recentLocation;
@end

@implementation DTMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.updateUserLocationFlag = false;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) { // iOS8+
        // Sending a message to avoid compile time error
        [[UIApplication sharedApplication] sendAction:@selector(requestWhenInUseAuthorization)
                                                   to:self.locationManager
                                                 from:self
                                             forEvent:nil];
    }
    
    CLAuthorizationStatus authorizationStatus= [CLLocationManager authorizationStatus];
    
    if (authorizationStatus == kCLAuthorizationStatusAuthorized ||
        authorizationStatus == kCLAuthorizationStatusAuthorizedAlways ||
        authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
        
        [self.locationManager startUpdatingLocation];
        self.mapView.showsUserLocation = YES;
        
    }
    UILongPressGestureRecognizer* longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [self.mapView addGestureRecognizer:longTap];

}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if(!self.updateUserLocationFlag)
    {
        [self gotoLocation];
    }
    self.updateUserLocationFlag = true;
}

-(void) gotoLocation
{
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.locationManager.location.coordinate, 500, 500);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    [self.mapView setRegion:adjustedRegion animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kDetailSegue]) {
        TagDetailControllerViewController* detailController = segue.destinationViewController;
        detailController.poi = self.recentLocation;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshAnnotations];
    [self daytrip].delegate = self;
    [self refreshAnnotations];
}

- (void) refreshAnnotations
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mapView removeAnnotations:self.mapView.annotations];
        for (id<MKAnnotation> a in self.daytrip.filteredLocations) {
            [self.mapView addAnnotation:a];
        }
        [self.view setNeedsLayout];
    });
}

#pragma mark - Model
- (void)modelUpdated
{
    [self refreshAnnotations];
}

- (DTDayTrip*) daytrip
{
    return [DTAppDelegate appDelegate].daytrip;
}

- (void) setupAnnotationWithGeocoder:(DTPOI*)tag location:(CLLocation*)location
{
    //Try to get the Local name for the user's location.
    [[[CLGeocoder alloc] init] reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        NSString* message = nil;
        if (!error) {
            MKPlacemark* mark = placemarks[0];
            //NSLog(@"setting up placemarks! %@", placemarks[0]);
            tag.placeName = mark.name;
            [tag setLatitude:mark.location.coordinate.latitude longitude:mark.location.coordinate.longitude];
            message = mark.name;
        } else {
            NSLog(@"Creating new pin");
            //if the name can't be located, still create a tag with the less-ressed data.
            CLLocationCoordinate2D coordinate = location.coordinate;
            [tag setLatitude:coordinate.latitude longitude:coordinate.longitude];
            message = [NSString stringWithFormat:@"%4.2f,%4.2f", coordinate.latitude, coordinate.longitude];
        }
        tag.configuredBySystem = YES;
        
        tag.name = message;
        [self.daytrip addPOI:tag];
        [self.mapView addAnnotation:tag];
        self.recentLocation = tag;
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
        
    }];
}

- (void) addLocationAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    CLLocation* location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    DTPOI* newTag = [[DTPOI alloc] init];
    [self setupAnnotationWithGeocoder:newTag location:location];
}

- (IBAction)addLocation:(id)sender {
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setDetailsLabelText:@"Locating..."];
    [hud setDimBackground:YES];
    
    CLLocationCoordinate2D centerCoord = self.mapView.centerCoordinate;
    [self addLocationAtCoordinate:centerCoord];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        DTPOI* t = [self.daytrip.filteredLocations lastObject];
        NSString* title = [alertView textFieldAtIndex:0].text;
        if (!title) title = t.placeName;
        t.name = title;
        [self.daytrip persist:t];
    }
}

#pragma mark - Map View

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (_waitingForLocation == YES) {
        _waitingForLocation = NO;
        [self addLocation:nil];
        MKCoordinateRegion reg = MKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, 1500, 1500);
        [mapView setRegion:reg animated:YES];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[DTPOI class]]) {
        MKPinAnnotationView* pin = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"pin"];
        if (!pin) {
            pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"];
            pin.canShowCallout = YES;
            UIButton* callout = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            pin.rightCalloutAccessoryView = callout;
            UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0., 0., 36., 36.)];
            pin.leftCalloutAccessoryView = imageView;
            pin.draggable = YES;
        }
        pin.annotation = annotation;
        [(UIImageView*)pin.leftCalloutAccessoryView setImage:[(DTPOI*)annotation image]];
        return pin;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    NSLog(@"hit %@", view.annotation);
    self.recentLocation = (DTPOI*) view.annotation;
    [self performSegueWithIdentifier:kDetailSegue sender:self];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
{
    DTPOI* annotation = (DTPOI*) annotationView.annotation;
    if (newState == MKAnnotationViewDragStateEnding && annotation.configuredBySystem) {
        CLLocationCoordinate2D co = [(DTPOI*) annotationView.annotation coordinate];
        CLLocation* cllocation = [[CLLocation alloc] initWithLatitude:co.latitude longitude:co.longitude];
        [self setupAnnotationWithGeocoder:annotation location:cllocation];
    }
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
    if (_waitingForLocation == YES) {
        _waitingForLocation = NO;
    }
    
    NSLog(@"failed to get user location error: %@", error);
    if ([error code] == kCLErrorDenied && [[error domain] isEqualToString:kCLErrorDomain]) {
        //user disabled location
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled"
                                                        message:@"Enable Location preferences in settings to tag new hot spots and find nearby ones."
                                                       delegate:self
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Could not locate you" message:@"Try again in a few minutes" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil] show];
    }
    
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateAfterMapRegion) object:nil];
    [self performSelector:@selector(updateAfterMapRegion) withObject:nil afterDelay:2];
}

#pragma mark - Actions

- (void) updateAfterMapRegion
{
    MKCoordinateRegion region = self.mapView.region;
    [self.daytrip queryRegion:region];
}

- (IBAction)updateFilter:(id)sender {
    FilterListViewController* flvc = [[FilterListViewController alloc] initWithSelectedCategories:[DTCategories filteredCategories] deleagte:self];
    [self.navigationController pushViewController:flvc animated:YES];
}

- (void)selectedCategories:(NSArray *)array
{
    [DTCategories setFilteredCategories:array];
    [self.daytrip runQuery:[DTCategories query]];
}

- (void) tapped:(UILongPressGestureRecognizer*)longPress
{
    if (longPress.state == UIGestureRecognizerStateRecognized) {
        CGPoint tapLocation = [longPress locationInView:self.mapView];
        CLLocationCoordinate2D mapLocation = [self.mapView convertPoint:tapLocation toCoordinateFromView:self.mapView];
        [self addLocationAtCoordinate:mapLocation];
    }
}


@end
