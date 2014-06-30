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
//    CGFloat red = 32.0/255.0;
//    CGFloat green = 68.0/255.0;
//    CGFloat blue = 51.0/255.0;

    CGFloat red = 56.0/255.0;
    CGFloat green = 65.0/255.0;
    CGFloat blue = 115.0/255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1];
}

+ (UIColor *)buttonColor
{
//    CGFloat red = 64.0/255.0;
//    CGFloat green = 254.0/255.0;
//    CGFloat blue = 189.0/255.0;

    CGFloat red = 183.0/255.0;
    CGFloat green = 255.0/255.0;
    CGFloat blue = 194.0/255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1];
}

+ (UIColor *)accentColor
{
//    return [UIColor whiteColor];
//    CGFloat red = 76.0/255.0;
//    CGFloat green = 61.0/255.0;
//    CGFloat blue = 255.0/255.0;

    CGFloat red = 0.0/255.0;
    CGFloat green = 0.0/255.0;
    CGFloat blue = 0.0/255.0;

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
//    CGFloat red = 224.0/255.0;
//    CGFloat green = 146.0/255.0;
//    CGFloat blue = 141.0/255.0;

    CGFloat red = 221.0/255.0;
    CGFloat green = 222.0/255.0;
    CGFloat blue = 21.0/255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1];
}

+(UIColor *)textColor
{
    CGFloat red = 248.0/255.0;
    CGFloat green = 227.0/255.0;
    CGFloat blue = 139.0/255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1];
}





@end