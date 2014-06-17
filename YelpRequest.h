//
//  YelpRequest.h
//  PubChatter
//
//  Created by David Warner on 6/17/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TDOAuth.h"
#import "YelpBar.h"

@interface YelpRequest : NSObject

-(void)getYelpJSONWithSearch:(NSString *)query andLongitude:(CGFloat)longitude andLatitude:(CGFloat)latitude;

@end
