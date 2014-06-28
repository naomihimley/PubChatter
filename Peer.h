//
//  Peer.h
//  PubChatter
//
//  Created by Yeah Right on 6/27/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Peer : NSManagedObject

@property (nonatomic, retain) NSString * peerID;
@property (nonatomic, retain) NSSet *messages;
@end

@interface Peer (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(NSManagedObject *)value;
- (void)removeMessagesObject:(NSManagedObject *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

@end
