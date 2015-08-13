
#import <UIKit/UIKit.h>

@interface DTEncodeImageURL : NSObject

-(NSMutableURLRequest *)EncodeImageForURL:(NSString*)BoundaryConstant withboundary:(NSString*)boundary withParams:(NSDictionary*)_params withImage:(UIImage*)imageToPost withFileParamConstant:(NSString*)FileParamConstant withURL:(NSURL*)requestURL;

@end
