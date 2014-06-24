//
//  Peer.h
//  PubChatter
//
//  Created by Yeah Right on 6/23/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Conversation;

@interface Peer : NSManagedObject

@property (nonatomic, retain) Conversation *conversation;

@end
