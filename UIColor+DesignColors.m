//
//  UIColor+DesignColors.m
//  PubChatter
//
//  Created by Yeah Right on 6/26/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import "UIColor+DesignColors.h"

@implementation UIColor (DesignColors)


+ (UIColor *)cellBackgroundColor
{
    CGFloat red = 56.0/255.0;
    CGFloat green = 66.0/255.0;
    CGFloat blue = 111.0/255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1];
}

+ (UIColor *)buttonColor
{
    CGFloat red = 139.0/255.0;
    CGFloat green = 20.0/255.0;
    CGFloat blue = 91.0/255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1];
}

+ (UIColor *)backgroundColor
{
    CGFloat red = 213.0/255.0;
    CGFloat green = 50.0/255.0;
    CGFloat blue = 125.0/255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1];
}

+ (UIColor *)navBarColor
{
    CGFloat red = 20.0/255.0;
    CGFloat green = 47.0/255.0;
    CGFloat blue = 89.0/255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1];}

+ (UIColor *)nameColor
{
    CGFloat red = 216.0/255.0;
    CGFloat green = 222.0/255.0;
    CGFloat blue = 81.0/255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1];
}





@end