#import "DTRootViewController.h"
#import "DTModelController.h"

#import "DTDataViewController.h"

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

-(void)setConnectionData:(NSMutableData*)connData
{
    
    
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
    
    NSString* password = self.passwordTextBox.text;
    
    [super performSegueWithIdentifier:@"LoginSegue" sender:self];

    
    //NSString *salt = [JFBCrypt generateSaltWithNumberOfRounds: 10];
    //NSString *hashedPassword = [JFBCrypt hashPassword: password withSalt: salt];
    
    //NSLog(hashedPassword);
    
    //NSURL *msgURL = [NSURL URLWithString:@"https://192.168.2.12:8443"];
    //[self httpsLogin: msgURL];
    
    //NSURLRequest *msgRequest = [NSURLRequest requestWithURL:msgURL cachePolicy:NSURLCacheStorageAllowed timeoutInterval:5.0];
    }

-(void) checkLoginCredentials
{
    
}

-(void) httpsLogin: (NSURL *) link
{
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:link];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"GET"];
    [[NSURLConnection alloc]initWithRequest:request delegate:self startImmediately:YES];
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    
    [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"recieved");
    
    NSString *s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@", s);
    
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
