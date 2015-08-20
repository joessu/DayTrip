//
//  DTEncodeImageURL.h
//  DayTrip
//
//  Created by Joe Andresen on 3/16/14.
//  Copyright (c) 2014 Joseph Andresen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DTEncodeImageURL : NSObject

-(NSMutableURLRequest *)EncodeImageForURL:(NSString*)BoundaryConstant withboundary:(NSString*)boundary withParams:(NSDictionary*)_params withImage:(UIImage*)imageToPost withFileParamConstant:(NSString*)FileParamConstant withURL:(NSURL*)requestURL;

@end
