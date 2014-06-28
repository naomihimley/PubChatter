//
//  MCManager.m
//  PubChatter
//
//  Created by Richard Fellure on 6/16/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import "MCManager.h"
#import <Parse/Parse.h>
#import "Peer.h"
#import "Message.h"

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
        self.foundPeersArray = [NSMutableArray array];
        self.fetchedResultsController = [[NSFetchedResultsController alloc]init];
    }
    return self;
}

-(void)dealloc
{
    self.session.delegate = nil;
    self.browser.delegate = nil;
    self.advertiser.delegate = nil;
    self.advertisingUsers = nil;
}

#pragma mark - MCSession Delegate Methods

-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    NSDictionary *dictionary = @{@"peerID": peerID,
                                 @"state": [NSNumber numberWithInt:state]};

        [[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidChangeStateNotification"
                                                            object:nil
                                                          userInfo:dictionary];
    NSLog(@"STATE %i", state);
}

-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    NSDictionary *dictionary = @{@"data": data,
                                 @"peerID": peerID};
    NSString *receivedText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidReceiveDataNotification"
                                                        object:nil
                                                      userInfo:dictionary];
    if (![self doesConversationExist:peerID])
    {
        Peer *peer = [NSEntityDescription insertNewObjectForEntityForName:@"Peer" inManagedObjectContext:moc];
        Message *message = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:moc];
        message.text = receivedText;
        message.isMyMessage = @0;
        message.timeStamp = [NSDate date];
        peer.peerID = peerID.displayName;
        [peer addMessagesObject:message];
        [moc save:nil];
        NSLog(@"creating a new conversation in didReceiveData");
    }
    else if ([self doesConversationExist:peerID])
    {
        NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Peer"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"peerID" ascending:YES]];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"peerID == %@", peerID.displayName];
        request.predicate = predicate;
        self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:moc sectionNameKeyPath:nil cacheName:nil];
        [self.fetchedResultsController performFetch:nil];
        //got the Peer who sent you the message
        NSMutableArray *array = (NSMutableArray *)[self.fetchedResultsController fetchedObjects];
        Peer *peer = [array firstObject];
        Message *message = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:moc];
        message.text = receivedText;
        message.isMyMessage = @0;
        message.timeStamp = [NSDate date];
        [peer addMessagesObject:message];
        [moc save:nil];
        NSLog(@"adding received message in didReceiveData");
    }
}
- (BOOL)doesConversationExist :(MCPeerID *)peerID
{
    if (peerID)
    {
        NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Peer"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"peerID" ascending:YES]];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"peerID == %@", peerID.displayName];
        request.predicate = predicate;

        self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:moc sectionNameKeyPath:nil cacheName:nil];
        [self.fetchedResultsController performFetch:nil];
        NSMutableArray *array = (NSMutableArray *)[self.fetchedResultsController fetchedObjects];
        if (array.count < 1)
        {
            NSLog(@"not returning any fetched results");
            return NO;
        }
        NSLog(@"the fetch returned something");
        return YES;
    }
    else
    {
        NSLog(@"the peer id was null");
        return NO;
    }
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
    NSDictionary *dictionary = @{@"peerID":peerID};
    self.invitationHandlerArray = [NSMutableArray arrayWithObject:[invitationHandler copy]];

    [[NSNotificationCenter defaultCenter]postNotificationName:@"MCReceivedInvitation" object:nil userInfo:dictionary];
}

#pragma mark - MCNearbyServiceBrowser Delegate Methods

-(void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{

    if (self.advertisingUsers.count == 0)
    {
        [self.advertisingUsers addObject:peerID];
        [self.foundPeersArray addObject:self.peerID];
        NSDictionary *dictionary = @{@"peerID": peerID};

        [[NSNotificationCenter defaultCenter]postNotificationName:@"MCFoundAdvertisingPeer" object:nil userInfo:dictionary];
    }
    else
    {
        if (![self.foundPeersArray containsObject:peerID.displayName])
        {
            NSLog(@"this shouldn't be a mutliple %@", peerID.displayName);
            [self.advertisingUsers addObject:peerID];
            NSDictionary *dictionary = @{@"peerID": peerID};

            NSLog(@"found Peer");

            [[NSNotificationCenter defaultCenter]postNotificationName:@"MCFoundAdvertisingPeer" object:nil userInfo:dictionary];
        }
    }

    [self.foundPeersArray addObject:peerID.displayName];
}

-(void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    [self.advertisingUsers removeObject:peerID];
    [self.foundPeersArray removeObjectAtIndex:[self.foundPeersArray indexOfObject:peerID.displayName]];

    NSDictionary *dictionary = @{@"peerID": peerID};
    [[NSNotificationCenter defaultCenter]postNotificationName:@"MCPeerStopAdvertising" object:nil userInfo:dictionary];
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
}

-(void)advertiseSelf:(BOOL)shouldAdvertise
{
    if (shouldAdvertise)
    {
        self.advertiser = [[MCNearbyServiceAdvertiser alloc]initWithPeer:self.peerID discoveryInfo:nil serviceType:@"pubchatservice"];
        self.advertiser.delegate = self;
        [self.advertiser startAdvertisingPeer];

    }

    else
    {
        [self.advertiser stopAdvertisingPeer];
        [self.browser stopBrowsingForPeers];
        self.browser = nil;
        self.advertiser = nil;
    }
}

-(void)startBrowsingForPeers
{
    self.browser = [[MCNearbyServiceBrowser alloc]initWithPeer:self.peerID serviceType:@"pubchatservice"];
    self.browser.delegate = self;
    [self.browser startBrowsingForPeers];
}


@end
