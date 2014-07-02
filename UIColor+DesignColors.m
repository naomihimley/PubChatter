//
//  UIColor+DesignColors.m
//  PubChatter
//
//  Created by Yeah Right on 6/26/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import "UIColor+DesignColors.h"

@implementation UIColor (DesignColors)


+ (UIColor *)backgroundColor
{

    CGFloat red = 56.0/255.0;
    CGFloat green = 65.0/255.0;
    CGFloat blue = 115.0/255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1];
}

+ (UIColor *)buttonColor
{

    CGFloat red = 183.0/255.0;
    CGFloat green = 255.0/255.0;
    CGFloat blue = 194.0/255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1];
}

+ (UIColor *)textColor
{

    CGFloat red = 218/255.0;
    CGFloat green = 218.0/255.0;
    CGFloat blue = 216.0/255.0;

    return [UIColor colorWithRed:red green:green blue:blue alpha:1];
}

+ (UIColor *)navBarColor
{
    CGFloat red = 35.0/255.0;
    CGFloat green = 30.0/255.0;
    CGFloat blue = 29.0/255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1];}

+ (UIColor *)nameColor
{
    CGFloat red = 255.0/255.0;
    CGFloat green = 255.0/255.0;
    CGFloat blue = 255.0/255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1];
}

+(UIColor *)accentColor
{
    CGFloat red = 248.0/255.0;
    CGFloat green = 227.0/255.0;
    CGFloat blue = 139.0/255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1];
}





@end