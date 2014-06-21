//
//  MCManager.m
//  PubChatter
//
//  Created by Richard Fellure on 6/16/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import "MCManager.h"
#import <Parse/Parse.h>

@implementation MCManager

-(id)init
{
    self = [super init];

    if (self)
    {
        self.peerID = nil;
        self.session = nil;
        self.browser = nil;
        self.advertiser = nil;
        self.advertisingUsers = [NSMutableArray array];
        self.advertisingUsersFromParse = [NSMutableArray array];

    }
    return self;
}

-(void)dealloc
{
    self.session.delegate = nil;
    self.browser.delegate = nil;
    self.advertiser.delegate = nil;
}

#pragma mark - MCSession Delegate Methods

-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    NSDictionary *dictionary = @{@"peerID": peerID,
                                 @"state": [NSNumber numberWithInt:state]};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidChangeStateNotification"
                                                        object:nil
                                                      userInfo:dictionary];

}

-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    NSDictionary *dictionary = @{@"data": data,
                                 @"peerID": peerID};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidReceiveDataNotification"
                                                        object:nil
                                                      userInfo:dictionary];
}

-(void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
}

-(void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
}

-(void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
}

#pragma mark - MCNearbyServiceAdvertiser Delegate methods

-(void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler
{

}

#pragma mark - MCNearbyServiceBrowser Delegate Methods

-(void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    [self.advertisingUsers addObject:peerID];
    NSLog(@"advertisingUsers %@", self.advertisingUsers);
//    [self.advertisingUsersFromParse addObject:info];
    NSLog(@"advertisingUsersFromParse %@", self.advertisingUsersFromParse);
    [[NSNotificationCenter defaultCenter]postNotificationName:@"MCFoundAdvertisingPeer" object:nil userInfo:nil];
    NSLog(@"found a peer");
}

-(void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    [self.advertisingUsers removeObject:peerID];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"MCFoundAdvertisingPeer" object:nil userInfo:nil];
}
-(void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
    NSLog(@"error %@", error);
}

# pragma mark - Public Methods

-(void)setupPeerAndSessionWithDisplayName:(NSString *)displayName
{
    self.peerID = [[MCPeerID alloc]initWithDisplayName:displayName];
    self.session = [[MCSession alloc]initWithPeer:self.peerID];
    self.session.delegate = self;
    NSLog(@"session delegate %@", self.session.delegate);
}

-(void)setupMCBrowser
{
    self.browser = [[MCNearbyServiceBrowser alloc]initWithPeer:self.peerID serviceType:@"pubchatservice"];
    self.browser.delegate = self;
    [self.browser startBrowsingForPeers];
}

-(void)advertiseSelf:(BOOL)shouldAdvertise
{
    if (shouldAdvertise)
    {
        PFUser *user = [PFUser currentUser];
//        NSDictionary *dictionary = @{@"age": [user objectForKey:@"age"],
//                                     @"gender": [user objectForKey:@"gender"]};
        self.advertiser = [[MCNearbyServiceAdvertiser alloc]initWithPeer:self.peerID discoveryInfo:nil serviceType:@"pubchatservice"];
        self.advertiser.delegate = self;
        [self.advertiser startAdvertisingPeer];
        NSLog(@"advertiser delegate %@", self.advertiser.delegate);
    }

    else
    {
        self.advertiser.delegate = self;
        [self.advertiser stopAdvertisingPeer];
        self.advertiser = nil;
    }
}
@end
