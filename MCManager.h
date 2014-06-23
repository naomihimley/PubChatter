//
//  MCManager.h
//  PubChatter
//
//  Created by Richard Fellure on 6/16/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface MCManager : NSObject<MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate>

@property MCPeerID *peerID;
@property MCSession *session;
@property MCNearbyServiceBrowser *browser;
@property MCNearbyServiceAdvertiser *advertiser;
@property NSMutableArray *advertisingUsers;
@property NSMutableArray *advertisingUsersFromParse;

-(void)setupPeerAndSessionWithDisplayName: (NSString *)displayName;
-(void)setupMCBrowser;
-(void)advertiseSelf: (BOOL)shouldAdvertise;

@end
