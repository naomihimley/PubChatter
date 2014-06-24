//
//  Conversation.h
//  PubChatter
//
//  Created by Yeah Right on 6/23/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Conversation : NSManagedObject

@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSManagedObject *peer;

@end
