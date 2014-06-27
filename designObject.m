//
//  designObject.m
//  PubChatter
//
//  Created by Yeah Right on 6/26/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import "designObject.h"

@implementation designObject

- (id)initWithDesigns
{
    self = [super init];
    self.pubChatPurple = [UIColor colorWithRed:56 green:66 blue:111 alpha:1];
    self.pubChatPink = [UIColor colorWithRed:139 green:20 blue:91 alpha:1];
    self.pubChatLightPink = [UIColor colorWithRed:213 green:50 blue:125 alpha:1];
    self.pubChatYellow = [UIColor colorWithRed:216 green:222 blue:81 alpha:1];
    self.pubChatBlue = [UIColor colorWithRed:20 green:47 blue:89 alpha:1];
    return self;
}

@end
