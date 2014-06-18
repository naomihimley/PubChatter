//
//  YelpBar.h
//  PubChatter
//
//  Created by David Warner on 6/16/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//


@interface YelpBar : NSObject

@property NSString *name;
@property NSString *address;
@property NSString *telephone;
@property CGFloat latitude;
@property CGFloat longitude;
@property (nonatomic, assign) CGFloat distanceFromUser;
@property NSString *businessURL;
@property NSString *businessImageURL;
@property NSString *businessRatingImageURL;
@property NSString *businessMobileURL;
@property NSString *aboutBusiness;
@property NSArray *categories;


@end
