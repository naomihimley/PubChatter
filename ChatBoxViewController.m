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
#import "Message.h"
#import "SWRevealViewController.h"
#import "UIColor+DesignColors.h"
#import "ChatTableViewCell.h"

@interface ChatBoxViewController ()<UITextFieldDelegate, UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITextField *chatTextField;
@property PFUser *chatingUser;
@property MCPeerID *chattingUserPeerID;
@property AppDelegate *appDelegate;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSArray *sortedArray;
@property ChatTableViewCell *customCell;
@property CGFloat chatTextFieldy;
@property CGFloat tableViewy;
@property (weak, nonatomic) IBOutlet UIView *chatFieldView;

-(void)didReceiveDataWithNotification: (NSNotification *)notification;
-(void)sendMyMessage;

@end

@implementation ChatBoxViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.chatTextFieldy = self.chatFieldView.frame.origin.y;
    self.tableViewy = self.tableView.frame.origin.y;
    self.sortedArray = [NSArray new];
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
    if (!self.chattingUserPeerID) {
        self.navigationItem.title = @"Not Chatting";
    }
    else
    {
        [self fetch];
    }
}


#pragma mark - TextField Delegate method

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self sendMyMessage];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView beginAnimations:@"Animate Up" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationBeginsFromCurrentState:YES];

    self.chatFieldView.frame = CGRectMake(self.chatFieldView.frame.origin.x,
                                          310,
                                          self.chatFieldView.frame.size.width,
                                          self.chatFieldView.frame.size.height);

    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x,
                                      100,
                                      self.tableView.frame.size.width,
                                      self.tableView.frame.size.height);
    [UIView commitAnimations];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [UIView beginAnimations:@"Animate Text Field Back" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationBeginsFromCurrentState:YES];

    self.chatFieldView.frame = CGRectMake(self.chatFieldView.frame.origin.x,
                                          self.chatTextFieldy,
                                          self.chatFieldView.frame.size.width,
                                          self.chatFieldView.frame.size.height);

    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x,
                                      self.tableViewy,
                                      self.tableView.frame.size.width,
                                      self.tableView.frame.size.height);

    [UIView commitAnimations];
}

#pragma mark - Notification Methods
//notification for receiving a text
- (void)didReceiveDataWithNotification:(NSNotification *)notification
{
    NSLog(@"notification in chatbox on receive a text");
    NSString *notificationDisplayName =[[[notification userInfo]objectForKey:@"peerID"] displayName];
    //if the data is coming from the person you're chatting with then add it to the text view
    if ([self.chattingUserPeerID.displayName isEqual:notificationDisplayName]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"if statement in notification");
            [self fetch];
        });
    }

}

//notification from when you click the "CHAT" button in the drawer
- (void)didReceivePeerToChatWithNotification: (NSNotification *)notification
{
    self.chattingUserPeerID = [[notification userInfo]objectForKey:@"peerID"];
    self.chatingUser = [[notification userInfo]objectForKey:@"user"];
    self.navigationItem.title = [self.chatingUser objectForKey:@"name"];
    [self fetch];
}

#pragma mark - FetchedResultsController Helper Methods
- (void)fetch
{
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Peer"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"peerID" ascending:YES]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"peerID == %@", self.chattingUserPeerID.displayName];
    request.predicate = predicate;
    self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:moc sectionNameKeyPath:nil cacheName:nil];
    [self.fetchedResultsController performFetch:nil];
    NSMutableArray *array = (NSMutableArray *)[self.fetchedResultsController fetchedObjects];
    Peer *peer = [array firstObject];
    if (peer.messages)
    {
        [self sort:peer.messages];
    }
    else
    {
        //load an empty tableView
        self.sortedArray = [NSArray new];
        [self.tableView reloadData];
    }
}

- (void)sort: (NSSet *)set
{
    NSLog(@"sort");
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:YES];
    self.sortedArray = [[set allObjects] sortedArrayUsingDescriptors:@[sorter]];
    [self.tableView reloadData];
    NSInteger lastRowNumber = [self.tableView numberOfRowsInSection:0] - 1;
    NSIndexPath* ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
    [self.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

# pragma mark - TableViewDelegate methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.customCell)
    {
        self.customCell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    }
    Message *message = [self.sortedArray objectAtIndex:indexPath.row];
    if ([message.isMyMessage isEqual: @0])
    {
        [self.customCell.leftLabel setText:message.text];
        self.customCell.leftLabel.lineBreakMode = NSLineBreakByCharWrapping;
    }
    else
    {
        [self.customCell.rightLabel setText:message.text];
        self.customCell.rightLabel.lineBreakMode = NSLineBreakByCharWrapping;
    }
    [self.customCell layoutIfNeeded];
    CGFloat height = [self.customCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sortedArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (self.sortedArray)
    {
        Message *message = [self.sortedArray objectAtIndex:indexPath.row];
        if ([message.isMyMessage isEqual: @0]) {
            [cell.leftLabel setText:message.text];
            self.customCell.leftLabel.lineBreakMode = NSLineBreakByCharWrapping;
            cell.leftLabel.textAlignment = NSTextAlignmentLeft;
            cell.rightLabel.text = @"";
//            cell.rightLabel.hidden = YES;
        }
        else
        {
            [cell.rightLabel setText: message.text];
            cell.rightLabel.textAlignment = NSTextAlignmentRight;
            self.customCell.rightLabel.lineBreakMode = NSLineBreakByCharWrapping;
            cell.leftLabel.text = @"";
//            cell.leftLabel.hidden = YES;
        }
    }
    return cell;
}

#pragma mark - Helper method implementations


- (void)sendMyMessage
{
    if (self.chattingUserPeerID)
    {
        NSString *userInput = self.chatTextField.text;
        NSData *dataToSend = [userInput dataUsingEncoding:NSUTF8StringEncoding];
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
            if ([self doesConversationExist:self.chattingUserPeerID] == NO)
            {
                Peer *peer = [NSEntityDescription insertNewObjectForEntityForName:@"Peer" inManagedObjectContext:moc];
                Message *message = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:moc];
                message.text = userInput;
                message.isMyMessage = @1;
                message.timeStamp = [NSDate date];
                peer.peerID = self.chattingUserPeerID.displayName;
                [peer addMessagesObject:message];
                [moc save:nil];
                [self fetch];
                NSLog(@"sending the first text");
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
                Message *message = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:moc];
                message.text = userInput;
                message.isMyMessage = @1;
                message.timeStamp = [NSDate date];
                [peer addMessagesObject:message];
                [moc save:nil];
                [self fetch];
                NSLog(@"sending a message");
            }
        }
    }
    self.chatTextField.text = @"";
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
    //should remove the current convo from moc
    self.navigationItem.title = @"Not Chatting";
    self.chatTextField.text = @"";
    self.chattingUserPeerID = nil;
    [self fetch];
    //should only disconnect user from the current chatting peer

    NSLog(@"%@", self.appDelegate.mcManager.session.connectedPeers);
//    for (MCPeerID *peer in self.appDelegate.mcManager.session.connectedPeers) {
//        if (peer.displayName isEqual:self.chattingUserPeerID.displayName) {
//            MCSession *session = [[MCSession ]]
//        }
//    }
//    self.appDelegate.mcManager.session.connectedPeers 

}

- (IBAction)onButtonPressedSendChat:(id)sender
{
    if (self.appDelegate.mcManager.session.connectedPeers.count > 0) {
        if(self.chattingUserPeerID)
        {
            [self sendMyMessage];
        }
        else
        {
            self.chattingUserPeerID = self.appDelegate.mcManager.session.connectedPeers[0];
            [self sendMyMessage];
        }
    }
    else
    {
        //user not connected to anyone
    }
}
@end
