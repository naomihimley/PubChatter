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
#import "SWRevealViewController.h"

@interface ChatBoxViewController ()<UITextFieldDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *chatTextField;
@property (weak, nonatomic) IBOutlet UITextView *chatTextView;
@property PFUser *chatingUser;
@property MCPeerID *chattingUserPeerID;
@property AppDelegate *appDelegate;

-(void)didReceiveDataWithNotification: (NSNotification *)notification;
-(void)sendMyMessage;

@end

@implementation ChatBoxViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.chatTextView.userInteractionEnabled = NO;
    self.managedObjectContext = moc;
    self.fetchedResultsController.delegate = self;
    self.fetchedResultsController = [[NSFetchedResultsController alloc]init];
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDataWithNotification:)
                                                 name:@"MCDidReceiveDataNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceivePeerToChatWithNotification:)
                                                 name:@"PeerToChatWith"
                                               object:nil];
    self.chatTextField.delegate = self;
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [self.view resignFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


#pragma mark - TextField Delegate method

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self sendMyMessage];
    return YES;
}

#pragma mark - Notification Methods
- (void)didReceiveDataWithNotification:(NSNotification *)notification
{
    self.chattingUserPeerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = [self.chatingUser objectForKey:@"name"];
    NSData *receivedData = [[notification userInfo] objectForKey:@"data"];
    NSString *receivedText = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];

    NSString *chatString = [NSString stringWithFormat:@"%@:\n%@\n\n", peerDisplayName, receivedText];
    [self.chatTextView performSelectorOnMainThread:@selector(setText:) withObject:[self.chatTextView.text stringByAppendingString:chatString] waitUntilDone:NO];
}

- (void)didReceivePeerToChatWithNotification: (NSNotification *)notification
{
    self.chattingUserPeerID = [[notification userInfo]objectForKey:@"peerID"];
    self.chatingUser = [[notification userInfo]objectForKey:@"user"];
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Peer"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"peerID" ascending:YES]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"peerID == %@", self.chattingUserPeerID.displayName];
    request.predicate = predicate;
    self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:moc sectionNameKeyPath:nil cacheName:nil];
    [self.fetchedResultsController performFetch:nil];
    NSMutableArray *array = (NSMutableArray *)[self.fetchedResultsController fetchedObjects];
    Peer *peer = [array firstObject];
    Conversation *convo = [peer.conversation anyObject];
    self.chatTextView.text = convo.message;
}

#pragma mark - Helper method implementations


- (void)sendMyMessage
{
    NSString *chatWithNewLine = [NSString stringWithFormat:@"\n %@", self.chatTextField.text];
    NSData *dataToSend = [chatWithNewLine dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Chatting User Peer ID? %@", self.chattingUserPeerID);
    NSArray *peerToSendTo = @[self.chattingUserPeerID];
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
        if ([self doesConversationExist:self.chattingUserPeerID] == NO)
        {
            Peer *peer = [NSEntityDescription insertNewObjectForEntityForName:@"Peer" inManagedObjectContext:self.managedObjectContext];
            Conversation *conversation = [NSEntityDescription insertNewObjectForEntityForName:@"Conversation" inManagedObjectContext:self.managedObjectContext];
            conversation.message = chatString;
            peer.peerID = self.chattingUserPeerID.displayName;
            [peer addConversationObject:conversation];
            [self.managedObjectContext save:nil];
            NSLog(@"CHATBOX creating new convo in sendMyMessage");
        }
        else
        {
            NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Peer"];
            request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"peerID" ascending:YES]];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"peerID == %@", self.chattingUserPeerID.displayName];
            request.predicate = predicate;
            self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:moc sectionNameKeyPath:nil cacheName:nil];
            [self.fetchedResultsController performFetch:nil];
            NSMutableArray *array = (NSMutableArray *)[self.fetchedResultsController fetchedObjects];
            Peer *peer = [array firstObject];
            Conversation *convo = [peer.conversation anyObject];
            NSString *chatWithNewLine = [NSString stringWithFormat: @"\n %@ \n", chatString];
            convo.message = [convo.message stringByAppendingString:chatWithNewLine];
            [self.managedObjectContext save:nil];
            NSLog(@"CHATBOX SENT adding message object: %@", convo.message);
        }

        self.chatTextField.text = @"";
    }
    [self.chatTextField resignFirstResponder];
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
            NSLog(@"not returning any fetched results in CHATBOX");
            return NO;
        }
        NSLog(@"the fetch returned something in CHATBOX");
        return YES;
    }
    else
    {
        NSLog(@"the peer id was null IN CHATBOX");
        return NO;
    }

}

# pragma mark - Button Actions

- (IBAction)onButtonPressedEndSession:(id)sender
{
    self.chatTextView.text = @"";
    self.chatTextField.text = @"";
    [self.appDelegate.mcManager.session disconnect];
}
- (IBAction)onButtonPressedCancelSendingChat:(id)sender
{
    self.chatTextField.text = @"";
    [self.chatTextField resignFirstResponder];
}

- (IBAction)onButtonPressedSendChat:(id)sender
{
    [self sendMyMessage];
}
@end
