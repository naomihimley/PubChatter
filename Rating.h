//
//  Rating.h
//  PubChatter
//
//  Created by David Warner on 6/23/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import <Parse/Parse.h>

@interface Rating : PFObject <PFSubclassing>

+(id)parseClassName;
@property NSNumber *rating;
@property NSString *user;
@property NSString *bar;


@end
