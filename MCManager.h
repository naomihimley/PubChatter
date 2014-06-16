//
//  MCManager.h
//  PubChatter
//
//  Created by Richard Fellure on 6/16/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface MCManager : NSObject<MCSessionDelegate>

@property MCPeerID *peerID;
@property MCSession *session;
@property MCBrowserViewController *browser;
@property MCAdvertiserAssistant *advertiser;

-(void)setupPeerAndSessionWithDisplayName: (NSString *)displayName;
-(void)setupMCBrowser;
-(void)advertiseSelf: (BOOL)shouldAdvertise;

@end
