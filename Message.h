//
//  Message.h
//  PubChatter
//
//  Created by Yeah Right on 6/27/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Peer;

@interface Message : NSManagedObject

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSNumber * isMyMessage;
@property (nonatomic, retain) Peer *peer;

@end
