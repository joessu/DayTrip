//
//  DTLoginData.m
//  DayTrip
//
//  Created by Joe Andresen on 7/28/14.
//  Copyright (c) 2014 Joseph Andresen. All rights reserved.
//

#import "DTLoginData.h"

@implementation DTLoginData

-(id)init {
    self = [super init];
    if(self)
    {
        self.loginData = [NSMutableDictionary dictionary];
    }
    return self;
}


-(void) setUsername:(NSString *)username {
    self.loginData[@"username"] = username;
}

-(NSString*) username {
    return self.loginData[@"username"];
}

-(void) setPassword:(NSString*) password {
    self.loginData[@"password"]= password;
}


@end
