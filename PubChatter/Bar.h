//
//  Bar.h
//  PubChatter
//
//  Created by David Warner on 6/15/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import <Parse/Parse.h>
#import <MapKit/MapKit.h>

@interface Bar : PFObject <PFSubclassing>

+(id)parseClassName;
@property NSString *name;
@property NSString *address;
@property CGFloat latitude;
@property CGFloat longitude;
@property (nonatomic, assign) CGFloat distanceFromUser;

@end
