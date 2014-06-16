//
//  Bar.h
//  PubChatter
//
//  Created by David Warner on 6/15/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface Bar : NSObject

@property NSString *name;
@property NSString *address;
@property NSURL *businessURL;
@property NSString *telephone;
@property CGFloat latitude;
@property CGFloat longitude;
@property BOOL isCurrentLocation;
@property (nonatomic, assign) CGFloat distanceFromUser;

@end
