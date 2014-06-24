//
//  Peer.h
//  PubChatter
//
//  Created by Yeah Right on 6/24/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Conversation;

@interface Peer : NSManagedObject

@property (nonatomic, retain) NSString * peerID;
@property (nonatomic, retain) NSSet *conversation;
@end

@interface Peer (CoreDataGeneratedAccessors)

- (void)addConversationObject:(Conversation *)value;
- (void)removeConversationObject:(Conversation *)value;
- (void)addConversation:(NSSet *)values;
- (void)removeConversation:(NSSet *)values;

@end
