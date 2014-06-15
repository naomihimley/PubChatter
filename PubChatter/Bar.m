//
//  Bar.m
//  PubChatter
//
//  Created by David Warner on 6/15/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import "Bar.h"

@implementation Bar

@dynamic name;
@dynamic address;
@dynamic latitude;
@dynamic longitude;
@dynamic distanceFromUser;

+(id)parseClassName
{
    return @"Bar";
}

@end
