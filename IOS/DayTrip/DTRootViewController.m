//
//  DTRootViewController.m
//  DayTrip
//
//  Created by Joe Andresen on 3/2/14.
//  Copyright (c) 2014 Joseph Andresen. All rights reserved.
//

#import "DTRootViewController.h"
#import "DTModelController.h"
#import "JFCommon-master/JFBCrypt.h"
#import "DTDataViewController.h"
#import "DTLoginData.h"

@interface DTRootViewController ()
@property (readonly, strong, nonatomic) DTModelController *modelController;
@end

@implementation DTRootViewController

static NSString* gAnswers[] = {
    @"Half",
    @"Ski",
    @"Rainy",
    @"Napa",
    @"Family",
    @"Sunny",
    @"Beach",
    @"Hiking",
    @"Fishing",
    @"Picnic"
};

static NSString* testLoginName = @"joessu";
static NSString* testLoginPassword = @"test";

+ (NSDictionary *)typeDisplayNames
{
    return @{@(registerRequest) : @"registerRequest",
             @(loginRequest) : @"loginRequest",
             @(getDayTrips) : @"getDayTrips",
             @(putDayTrip) : @"putDayTrip",
             @(getDayTripDetailed) : @"getDayTripDetailed",
             @(ProtocolUnknown) : @"ProtocolUnknown"};
}

#define kNumberOfAnswers (sizeof(gAnswers)/sizeof(NSString*))

//#define kMessageBoardServerURLString @"http://localhost:8080/”

@synthesize modelController = _modelController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self newFlavorText];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (DTModelController *)modelController
{
     // Return the model controller object, creating it if necessary.
     // In more complex implementations, the model controller may be passed to the view controller.
    if (!_modelController) {
        _modelController = [[DTModelController alloc] init];
    }
    return _modelController;
}

- (IBAction)dismissKeyboard:(id)sender
{
    [self.view endEditing:NO];
}

- (IBAction)clearTextAndSetAsSecure:(id)sender
{
    [self.passwordTextBox setText:(@"")];
    [self.passwordTextBox setSecureTextEntry:(true)];
}

- (void)fadeFlavorText
{
    [UIView animateWithDuration:0.75 animations:^{
        self.flavorTextLabel.alpha = 0.0;
    }];
    
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(newFlavorText) userInfo:nil repeats:NO];
}

- (NSString *)typeDisplayName {
    return [[self class] typeDisplayNames][@(self.type)];
}

-(IBAction)loginRequest:(id)sender
{
    if (!self.passwordTextBox.hasText) {
        return;
    }
    
    [NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(checkLoginCredentials) userInfo:nil repeats:NO];
    
    NSString* username = self.loginName.text;
    NSString* password = self.passwordTextBox.text;
    
    DTLoginData* logindata = [[DTLoginData alloc] init];
    [logindata setUsername:username];
    [logindata setPassword:password];
    NSError* error = nil;
    
    NSData* data = [NSJSONSerialization  dataWithJSONObject:logindata.loginData options:0 error:&error];
    NSURL *msgURL = [NSURL URLWithString:@"https://127.0.0.1:8000"];
    [self httpsLogin: msgURL data:data];
}

-(void) checkLoginCredentials
{
    
}

-(void) httpsLogin:(NSURL *)link data:(NSData*)data
{
    unsigned long length = [data length];
    NSLog(@"length: %lul",length);
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:link];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[data length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: data];
    
    // Must set a delegate here or we can't test with self-signed certificates
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        NSDictionary *dictionary = [httpResponse allHeaderFields];
        NSLog(@"%@", dictionary[@"Content-Type"]);
        NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }] resume];
    
    [super performSegueWithIdentifier:@"LoginSegue" sender:self];

}

// FIXME: Should be able to remove when we get a CA signed SSL cert
- (void)URLSession:(NSURLSession *)session
      didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
        completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{
    NSLog(@"URLSession didReceiveChallenge: %@", challenge);
    
    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
        if([challenge.protectionSpace.host isEqualToString:@"127.0.0.1"]){
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
        }
    }
}

- (void)newFlavorText
{
    self.flavorTextLabel.text = gAnswers[arc4random_uniform(kNumberOfAnswers)];
    
    [UIView animateWithDuration:2.0 animations:^{
        self.flavorTextLabel.alpha = 1.0;
    }];
    
    [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(fadeFlavorText) userInfo:nil repeats:NO];

}

@end


