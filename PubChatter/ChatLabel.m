//
//  ChatLabel.m
//  PubChatter
//
//  Created by David Warner on 7/3/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import "ChatLabel.h"

@implementation ChatLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = {5, 5, 5, 5};
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
