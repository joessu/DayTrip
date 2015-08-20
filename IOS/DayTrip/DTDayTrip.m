//
//  DTDayTrip.m
//  DayTrip
//
//  Created by Joe Andresen on 1/10/15.
//  Copyright (c) 2015 Joseph Andresen. All rights reserved.
//

#import "DTDayTrip.h"
#import "DTPOI.h"

static NSString* const kBaseURL = @"http://24.143.229.49:3000/";
static NSString* const kPOIS = @"pois";
static NSString* const kFiles = @"files";

@interface DTDayTrip ()
@property (nonatomic, strong) NSMutableArray* objects;
@end

@implementation DTDayTrip
- (id)init
{
    self = [super init];
    if (self) {
        _objects = [NSMutableArray array];
    }
    return self;
}

- (NSArray*) filteredLocations
{
    return [self objects];
}

- (void) addPOI:(DTPOI*)poi
{
    [self.objects addObject:poi];
}

- (void)loadImage:(DTPOI*)poi
{
    NSURL* url = [NSURL URLWithString:[[kBaseURL stringByAppendingPathComponent:kFiles] stringByAppendingPathComponent:poi.imageId]]; //1
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDownloadTask* task = [session downloadTaskWithURL:url completionHandler:^(NSURL *fileLocation, NSURLResponse *response, NSError *error) { //2
        if (!error) {
            NSData* imageData = [NSData dataWithContentsOfURL:fileLocation]; //3
            UIImage* image = [UIImage imageWithData:imageData];
            if (!image) {
                NSLog(@"unable to build image");
            }
            poi.image = image;
            if (self.delegate) {
                [self.delegate modelUpdated];
            }
        }
    }];
    
    [task resume]; //4
}

- (void)parseAndAddLocations:(NSArray*)locations toArray:(NSMutableArray*)destinationArray
{
    for (NSDictionary* item in locations) {
        DTPOI* poi = [[DTPOI alloc] initWithDictionary:item]; //2
        [destinationArray addObject:poi];
        
        if (poi.imageId) { //1
            [self loadImage:poi];
        }
    }
    
    if (self.delegate) {
        [self.delegate modelUpdated]; //3
    }
}

- (void)import
{
    NSURL* url = [NSURL URLWithString:[kBaseURL stringByAppendingPathComponent:kPOIS]]; //1
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET"; //2
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"]; //3
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration]; //4
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) { //5
        if (error == nil) {
            NSArray* responseArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL]; //6
            [self parseAndAddLocations:responseArray toArray:self.objects]; //7
        }
    }];
    
    [dataTask resume]; //8
}

- (void) runQuery:(NSString *)queryString
{
    NSString* urlStr = [[kBaseURL stringByAppendingPathComponent:kPOIS] stringByAppendingString:queryString]; //1
    NSURL* url = [NSURL URLWithString:urlStr];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            [self.objects removeAllObjects]; //2
            NSArray* responseArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            NSLog(@"received %lu items", (unsigned long)responseArray.count);
            [self parseAndAddLocations:responseArray toArray:self.objects];
        }
    }];
    [dataTask resume];
}

- (void) queryRegion:(MKCoordinateRegion)region
{
    NSLog(@"Query Region......");
    //note assumes the NE hemisphere. This logic should really check first.
    //also note that searches across hemisphere lines are not interpreted properly by Mongo
    CLLocationDegrees x0 = region.center.longitude - region.span.longitudeDelta; //1
    CLLocationDegrees x1 = region.center.longitude + region.span.longitudeDelta;
    CLLocationDegrees y0 = region.center.latitude - region.span.latitudeDelta;
    CLLocationDegrees y1 = region.center.latitude + region.span.latitudeDelta;
    
    NSString* boxQuery = [NSString stringWithFormat:@"{\"$geoWithin\":{\"$box\":[[%f,%f],[%f,%f]]}}",x0,y0,x1,y1]; //2
    NSString* locationInBox = [NSString stringWithFormat:@"{\"location\":%@}", boxQuery]; //3
    NSString* escBox = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                             (CFStringRef) locationInBox,
                                                                                             NULL,
                                                                                             (CFStringRef) @"!*();':@&=+$,/?%#[]{}",
                                                                                             kCFStringEncodingUTF8)); //4
    NSString* query = [NSString stringWithFormat:@"?query=%@", escBox]; //5
    [self runQuery:query]; //7
}


- (void) persist:(DTPOI*)poi
{
    if (!poi || poi.name == nil || poi.name.length == 0) {
        return; //input safety check
    }
    
    //if there is an image, save it first
    if (poi.image != nil && poi.imageId == nil) { //1
        [self saveNewLocationImageFirst:poi]; //2
        return;
    }
    
    NSString* pois = [kBaseURL stringByAppendingPathComponent:kPOIS];
    BOOL isExistingLocation = poi._id != nil;
    NSLog(@"isExistingLocation: %d",isExistingLocation);
    
    NSURL* url = isExistingLocation ? [NSURL URLWithString:[pois stringByAppendingPathComponent:poi._id]] :
    [NSURL URLWithString:pois]; //1
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    
    NSData* data = [NSJSONSerialization dataWithJSONObject:[poi toDictionary] options:0 error:NULL]; //3
    
    if(isExistingLocation) {
        [request setHTTPMethod:@"PUT"];
    } else {
        [request setHTTPMethod:@"POST"];
    }
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [data length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: data];
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) { //5
        if (!error) {
            NSArray* responseArray = @[[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL]];
            [self parseAndAddLocations:responseArray toArray:self.objects];
        }
    }];
    [dataTask resume];
}

- (void) saveNewLocationImageFirst:(DTPOI*)poi
{
    NSURL* url = [NSURL URLWithString:[kBaseURL stringByAppendingPathComponent:kFiles]]; //1
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST"; //2
    [request addValue:@"image/png" forHTTPHeaderField:@"Content-Type"]; //3
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    
    NSData* bytes = UIImagePNGRepresentation(poi.image); //4
    NSURLSessionUploadTask* task = [session uploadTaskWithRequest:request fromData:bytes completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) { //5
        if (error == nil && [(NSHTTPURLResponse*)response statusCode] < 300) {
            NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            poi.imageId = responseDict[@"_id"]; //6
            [self persist:poi]; //7
        }
    }];
    [task resume];
}

@end
