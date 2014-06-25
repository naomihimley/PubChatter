//
//  ChatBoxViewController.m
//  PubChatter
//
//  Created by Richard Fellure on 6/16/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import "ChatBoxViewController.h"
#import "AppDelegate.h"
#import "Peer.h"
#import "Conversation.h"

@interface ChatBoxViewController ()<UITextFieldDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *chatTextField;
@property (weak, nonatomic) IBOutlet UITextView *chatTextView;
@property AppDelegate *appDelegate;

-(void)didReceiveDataWithNotification: (NSNotification *)notification;
-(void)sendMyMessage;

@end

@implementation ChatBoxViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.managedObjectContext = moc;
    self.fetchedResultsController.delegate = self;
    self.fetchedResultsController = [[NSFetchedResultsController alloc]init];
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDataWithNotification:)
                                                 name:@"MCDidReceiveDataNotification"
                                               object:nil];

    self.chatTextField.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    for (NSString *chat in self.chatArray)
    {
        self.chatTextView.text = chat;
    }
}

- (IBAction)onButtonPressedCancelSendingChat:(id)sender
{
    [self.chatTextField resignFirstResponder];
}

- (IBAction)onButtonPressedSendChat:(id)sender
{
    [self sendMyMessage];
}

#pragma mark - TextField Delegat method

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self sendMyMessage];
    return YES;
}

#pragma mark - Helper method implementation

-(void)sendMyMessage
{
    NSData *dataToSend = [self.chatTextField.text dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *peerToSendTo = self.appDelegate.mcManager.session.connectedPeers;
    NSError *error;
    [self.appDelegate.mcManager.session sendData:dataToSend
                                         toPeers:peerToSendTo
                                        withMode:MCSessionSendDataReliable
                                           error:&error];
    if (error)
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Connection to User has been lost"
                                                           message:nil
                                                          delegate:self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil, nil];
        [alertView show];
    }

    else
    {
        NSString *chatString = [NSString stringWithFormat:@"I wrote:\n%@\n\n", self.chatTextField.text];
        [self.chatTextView setText:[self.chatTextView.text stringByAppendingString:chatString]];
        //passed peerID from left drawer
        MCPeerID *peerID = [self.userDictionary objectForKey:@"peerID"];
        if ([self doesConversationExist:peerID] == NO)
        {
            Peer *peer = [NSEntityDescription insertNewObjectForEntityForName:@"Peer" inManagedObjectContext:self.managedObjectContext];
            Conversation *conversation = [NSEntityDescription insertNewObjectForEntityForName:@"Conversation" inManagedObjectContext:self.managedObjectContext];
            conversation.message = chatString;
            peer.peerID = peerID.displayName;
            [peer addConversationObject:conversation];
            [self.managedObjectContext save:nil];
//            NSLog(@"creating new convo in sendMyMessage");
        }
        else
        {
            NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Peer"];
            request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"peerID" ascending:YES]];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"peerID == %@", peerID.displayName];
            request.predicate = predicate;
            self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:moc sectionNameKeyPath:nil cacheName:nil];
            [self.fetchedResultsController performFetch:nil];
            NSMutableArray *array = (NSMutableArray *)[self.fetchedResultsController fetchedObjects];
            Peer *peer = [array firstObject];
            peer.peerID = peerID.displayName;
            Conversation *convo = [peer.conversation anyObject];
            convo.message = [convo.message stringByAppendingString:chatString];
            [self.managedObjectContext save:nil];
//            NSLog(@"SENT adding message object: %@", convo.message);
        }

        [self.chatArray addObject:chatString];
        self.chatTextField.text = @"";
    }
    [self.chatTextField resignFirstResponder];
}

-(void)didReceiveDataWithNotification:(NSNotification *)notification
{
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;

    NSData *receivedData = [[notification userInfo] objectForKey:@"data"];
    NSString *receivedText = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];

    NSString *chatString = [NSString stringWithFormat:@"%@:\n%@\n\n", peerDisplayName, receivedText];
    [self.chatTextView performSelectorOnMainThread:@selector(setText:) withObject:[self.chatTextView.text stringByAppendingString:chatString] waitUntilDone:NO];
    [self.chatArray addObject:chatString];

    if ([self doesConversationExist:peerID] == NO) {
        Peer *peer = [NSEntityDescription insertNewObjectForEntityForName:@"Peer" inManagedObjectContext:self.managedObjectContext];
        Conversation *conversation = [NSEntityDescription insertNewObjectForEntityForName:@"Conversation" inManagedObjectContext:self.managedObjectContext];
        conversation.message = chatString;
        peer.peerID = peerID.displayName;
        [peer addConversationObject:conversation];
        [self.managedObjectContext save:nil];
//        NSLog(@"RECEIVE making new convo w message: %@", conversation.message);
    }
    else
    {
        NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Peer"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"peerID" ascending:YES]];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"peerID == %@", peerID.displayName];
        request.predicate = predicate;
        self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:moc sectionNameKeyPath:nil cacheName:nil];
        [self.fetchedResultsController performFetch:nil];
        NSMutableArray *array = (NSMutableArray *)[self.fetchedResultsController fetchedObjects];
        Peer *peer = [array firstObject];
        peer.peerID = peerID.displayName;
        Conversation *convo = [peer.conversation anyObject];
        convo.message = [convo.message stringByAppendingString:chatString];
        [self.managedObjectContext save:nil];
//        NSLog(@"RECEIVE adding message: %@", convo.message);
    }
}

- (BOOL)doesConversationExist :(MCPeerID *)peerID
{
//    NSLog(@"the passed in peer id %@", peerID.displayName);
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
//            NSLog(@"not returning any fetched results");
            return NO;
        }
//        NSLog(@"the fetch returned something");
        return YES;
    }
    else
    {
//        NSLog(@"the peer id was null");
        return NO;
    }

}

# pragma mark - Disconnect from session

- (IBAction)onButtonPressedEndSession:(id)sender
{
    [self.appDelegate.mcManager.session disconnect];
}

@end
