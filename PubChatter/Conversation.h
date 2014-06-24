//
//  Conversation.h
//  PubChatter
//
//  Created by Yeah Right on 6/24/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Peer;

@interface Conversation : NSManagedObject

@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) Peer *peer;

@end
