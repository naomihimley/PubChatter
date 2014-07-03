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
        self.randomNumber = arc4random_uniform(100);
        self.shouldInvite = NO;
        self.connectedArray = [NSMutableArray array];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(makeInviter) name:@"MakeInviter" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(applicationDidEnterBackground:) name:@"UIApplicationEnteredBackground" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(applicationWillEnterForeground:) name:@"UIApplicationEnteredForeground" object:nil];
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

#pragma mark - Establishing a Inviter

-(void)makeInviter
{
    NSLog(@"Received notification to become the inviter");
    self.shouldInvite = YES;
}

#pragma mark - MCSession Delegate Methods

-(void)session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate fromPeer:(MCPeerID *)peerID certificateHandler:(void (^)(BOOL))certificateHandler
{
    certificateHandler(YES);
}

-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    NSDictionary *dictionary = @{@"peerID": peerID,
                                 @"state": [NSNumber numberWithInt:state]};
    
    NSLog(@"PEER Changing STATE %@: %i", peerID.displayName, state);

        [[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidChangeStateNotification"
                                                            object:nil
                                                        userInfo:dictionary];
    if (state == MCSessionStateConnected)
    {
        [self.connectedArray addObject:peerID.displayName];

//        NSLog(@"connectedArray before loop %@", self.connectedArray);
//
//        if (self.shouldInvite == YES)
//        {
//            for (NSString *displayName in self.foundPeersArray)
//            {
//                if (![displayName isEqual:self.peerID.displayName])
//                {
//                    if (![self.connectedArray containsObject:displayName])
//                    {
//                        NSLog(@"displayName of peer who made it through %@", displayName);
//                        NSLog(@"displayName of found advertising peers %@, connectedArray %@", self.foundPeersArray, self.connectedArray);
//                        [self.browser invitePeer:peerID toSession:self.session withContext:nil timeout:30.0];
//                    }
////
//                }
//            }
//        }
    }

    if (state == MCSessionStateNotConnected)
    {
        [self.foundPeersArray removeObject:peerID.displayName];
        [self.connectedArray removeObject:peerID.displayName];
    }
}

-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    NSDictionary *dictionary = @{@"data": data,
                                 @"peerID": peerID};
    NSString *receivedText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (![self doesConversationExist:peerID])
    {
        //first text
        Peer *peer = [NSEntityDescription insertNewObjectForEntityForName:@"Peer" inManagedObjectContext:moc];
        Message *message = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:moc];
        message.text = receivedText;
        message.isMyMessage = @0;
        message.timeStamp = [NSDate date];
        peer.peerID = peerID.displayName;
        [peer addMessagesObject:message];
        [moc save:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidReceiveDataNotification"
                                                            object:nil
                                                          userInfo:dictionary];
    }
    else if ([self doesConversationExist:peerID])
    {
        NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Peer"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"peerID" ascending:YES]];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"peerID == %@", peerID.displayName];
        request.predicate = predicate;
        self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request
                                                                           managedObjectContext:moc
                                                                             sectionNameKeyPath:nil
                                                                                      cacheName:nil];
        [self.fetchedResultsController performFetch:nil];
        //got the Peer who sent you the message
        NSMutableArray *array = (NSMutableArray *)[self.fetchedResultsController fetchedObjects];
        Peer *peer = [array firstObject];
        Message *message = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:moc];
        message.text = receivedText;
        message.isMyMessage = @0;
        message.timeStamp = [NSDate date];
        [peer addMessagesObject:message];
        if ([moc save:nil]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidReceiveDataNotification"
                                                                object:nil
                                                              userInfo:dictionary];
        }
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

        self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request
                                                                           managedObjectContext:moc
                                                                             sectionNameKeyPath:nil cacheName:nil];
        [self.fetchedResultsController performFetch:nil];
        NSMutableArray *array = (NSMutableArray *)[self.fetchedResultsController fetchedObjects];
        if (array.count < 1)
        {
            return NO;
        }
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma mark - MCNearbyServiceAdvertiser Delegate methods

-(void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler
{

    NSLog(@"This peer should now be an accepter");

    if (self.shouldInvite == NO)
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"MCJustAccepts"
                                                           object:nil
                                                         userInfo:nil];

        invitationHandler(YES, self.session);
    }
}

#pragma mark - MCNearbyServiceBrowser Delegate Methods

-(void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    if (self.shouldInvite == YES)
    {
        if (![self.connectedArray containsObject:peerID.displayName])
        {

            NSString *string = [NSString stringWithFormat:@"%i", self.randomNumber];
            
            NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];

            [browser invitePeer:peerID toSession:self.session withContext:data timeout:30.0];
        }
    }

    if (self.advertisingUsers.count == 0 && peerID.displayName != self.peerID.displayName)
    {
        [self.advertisingUsers addObject:peerID];
        [self.foundPeersArray addObject:self.peerID.displayName];
        NSDictionary *dictionary = @{@"peerID": peerID};

        [[NSNotificationCenter defaultCenter]postNotificationName:@"MCFoundAdvertisingPeer"
                                                           object:nil
                                                         userInfo:dictionary];
    }
    else
    {
        if (![self.foundPeersArray containsObject:peerID.displayName])
        {
            [self.advertisingUsers addObject:peerID];
            NSDictionary *dictionary = @{@"peerID": peerID};

            [[NSNotificationCenter defaultCenter]postNotificationName:@"MCFoundAdvertisingPeer"
                                                               object:nil
                                                             userInfo:dictionary];
        }
    }
    [self.foundPeersArray addObject:peerID.displayName];
}

-(void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    [self.advertisingUsers removeObject:peerID];

    NSDictionary *dictionary = @{@"peerID": peerID};
    NSLog(@"peer stopped advertising %@", peerID.displayName);
    [[NSNotificationCenter defaultCenter]postNotificationName:@"MCPeerStopAdvertising"
                                                       object:nil
                                                     userInfo:dictionary];
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
        self.advertiser = [[MCNearbyServiceAdvertiser alloc]initWithPeer:self.peerID
                                                           discoveryInfo:nil
                                                             serviceType:@"pubchatservice"];
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

-(void)teardownSession
{
    [self.session disconnect];
    self.session.delegate = nil;
    self.session = nil;

    [self advertiseSelf:NO];
    self.advertiser.delegate = nil;
    self.advertiser = nil;

    self.browser.delegate = nil;
    self.browser = nil;

    self.peerID = nil;

    self.shouldInvite = NO;
    [self.foundPeersArray removeAllObjects];
    [self.connectedArray removeAllObjects];
    [self.advertisingUsers removeAllObjects];
}

#pragma mark - Notifications of change of state of the application

-(void)applicationDidEnterBackground:(NSNotification *)notification
{
    self.backgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        NSLog(@"Background time expired; killing multipeer session");
        NSLog(@"Background stuff happened");
        [self teardownSession];
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskId];
        self.backgroundTaskId= UIBackgroundTaskInvalid;
    }];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    if (self.backgroundTaskId != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskId];
        self.backgroundTaskId = UIBackgroundTaskInvalid;
    }
}

#pragma mark - Unused Delegate Methods


-(void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    NSLog(@"E: %@", error);
}

-(void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
}

-(void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
}

@end
