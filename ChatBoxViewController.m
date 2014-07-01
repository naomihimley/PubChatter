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

@interface ChatBoxViewController ()<UITextFieldDelegate, UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource, SWRevealViewControllerDelegate>
@property PFUser *chatingUser;
@property MCPeerID *chattingUserPeerID;
@property AppDelegate *appDelegate;
@property NSArray *sortedArray;
@property ChatTableViewCell *customCell;
@property CGFloat viewy;
@property BOOL isUserInteration;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *chatFieldView;
@property (weak, nonatomic) IBOutlet UITextField *chatTextField;
@property (weak, nonatomic) IBOutlet UIView *sendView;
@property (strong, nonatomic) IBOutlet UIButton *findPubChattersButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UILabel *barLabel;
-(void)userEnteredBar:(NSNotification *)notification;
-(void)didReceiveDataWithNotification: (NSNotification *)notification;
-(void)sendMyMessage;

@end

@implementation ChatBoxViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.revealViewController.delegate = self;
    [self.findPubChattersButton addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];

    self.sortedArray = [NSArray new];
    self.fetchedResultsController.delegate = self;
    self.fetchedResultsController = [[NSFetchedResultsController alloc]init];
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    [[NSNotificationCenter defaultCenter]postNotificationName:@"chatBox"
                                                       object:nil
                                                     userInfo:@{@"toBeaconRegionManager": @"whatBarAmIIn"}];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDataWithNotification:)
                                                 name:@"MCDidReceiveDataNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceivePeerToChatWithNotification:)
                                                 name:@"PeerToChatWith"
                                               object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(userEnteredBar:)
                                                name:@"userEnteredBar"
                                              object:nil];
    self.chatTextField.delegate = self;
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [self.view resignFirstResponder];
    self.viewy = self.view.frame.origin.y;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.isUserInteration = YES;
    self.tableView.userInteractionEnabled = YES;
    self.tabBarController.tabBar.userInteractionEnabled = YES;
    if (!self.chattingUserPeerID) {
        self.navigationItem.title = @"Not Chatting";
    }
    else
    {
        [self fetch];
    }
    [self style];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - TextField Delegate method

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self sendMyMessage];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{

        [UIView animateWithDuration:0.25 animations:^{
            self.view.center = CGPointMake(self.view.center.x, self.view.center.y - 160);
        }];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.25 animations:^{
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.viewy, self.view.frame.size.width, self.view.frame.size.height);

    }];
}

#pragma mark - Notification Methods
//notification for receiving a text
- (void)didReceiveDataWithNotification:(NSNotification *)notification
{
    NSString *notificationDisplayName =[[[notification userInfo]objectForKey:@"peerID"] displayName];
    if ([self.chattingUserPeerID.displayName isEqual:notificationDisplayName]) {
        dispatch_async(dispatch_get_main_queue(), ^{
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

- (void)userEnteredBar: (NSNotification *)notification
{
    self.barLabel.text = [[notification userInfo] objectForKey:@"barName"];
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
        //load an empty tableView because you dont have a conversation started with that person.
        self.sortedArray = [NSArray new];
        [self.tableView reloadData];

    }
}

- (void)sort: (NSSet *)set
{
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:YES];
    self.sortedArray = [[set allObjects] sortedArrayUsingDescriptors:@[sorter]];
    [self.tableView reloadData];

    NSInteger lastRowNumber = [self.tableView numberOfRowsInSection:0] - 1;
    NSIndexPath* ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
    [self.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:NO];
}
#pragma mark - ScrollView Method
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
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
            self.customCell.leftLabel.lineBreakMode = NSLineBreakByWordWrapping;
        }
        else
        {
            [self.customCell.rightLabel setText:message.text];
            self.customCell.rightLabel.lineBreakMode = NSLineBreakByWordWrapping;
        }

        [self.customCell layoutIfNeeded];
        CGFloat height = [self.customCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        return height;
}

//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 70;
//}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sortedArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.backgroundColor = [UIColor clearColor];
    cell.leftLabel.textColor = [UIColor whiteColor];
    cell.rightLabel.textColor = [UIColor whiteColor];
    cell.leftLabel.layer.cornerRadius = 10.0f;
    cell.leftLabel.layer.masksToBounds = YES;
    cell.rightLabel.layer.cornerRadius = 10.0f;
    cell.rightLabel.layer.masksToBounds = YES;

    if (self.sortedArray)
    {
        Message *message = [self.sortedArray objectAtIndex:indexPath.row];
        if ([message.isMyMessage isEqual: @0]) {
            [cell.leftLabel setText:message.text];
            cell.leftLabel.textAlignment = NSTextAlignmentLeft;
            cell.leftLabel.backgroundColor = [[UIColor accentColor] colorWithAlphaComponent:0.9];
            cell.leftLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.leftLabel.hidden = NO;
            cell.rightLabel.hidden = YES;
        }
        else
        {
            [cell.rightLabel setText: message.text];
            cell.rightLabel.backgroundColor = [UIColor backgroundColor];
            cell.rightLabel.textAlignment = NSTextAlignmentRight;
            cell.rightLabel.backgroundColor = [[UIColor backgroundColor] colorWithAlphaComponent:0.9];
            cell.rightLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.rightLabel.hidden = NO;
            cell.leftLabel.hidden = YES;
        }
    }
    return cell;
}

#pragma mark - Reveal Delegate Method

- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position
{
    if (self.isUserInteration)
    {
        self.tableView.userInteractionEnabled = NO;
        self.tabBarController.tabBar.userInteractionEnabled = NO;
        self.isUserInteration = NO;
    }
    else
    {
        self.tableView.userInteractionEnabled = YES;
        self.tabBarController.tabBar.userInteractionEnabled = YES;
        self.isUserInteration = YES;
    }
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
- (IBAction)onButtonPressedSendChat:(id)sender
{

    if (self.appDelegate.mcManager.session.connectedPeers.count > 0) {
        if(self.chattingUserPeerID)
        {
            if (self.chatTextField.text && self.chatTextField.text.length > 0) {
                [self sendMyMessage];
            }
        }
        else
        {
            self.chattingUserPeerID = self.appDelegate.mcManager.session.connectedPeers[0];
            if (self.chatTextField.text && self.chatTextField.text.length > 0) {
                [self sendMyMessage];
            }
        }
    }
    else
    {
        NSLog(@"connected peers array is zero,because YOUR state is disconnected should we have an alert?");
    }
}

#pragma  mark - Style Method
- (void)style
{
    self.sendView.backgroundColor = [[UIColor backgroundColor] colorWithAlphaComponent:0.9];
    [self.sendButton setTitleColor:[UIColor buttonColor] forState:UIControlStateHighlighted];
    [self.sendButton setTitleColor:[UIColor buttonColor] forState:UIControlStateSelected];
    [self.sendButton setTitleColor:[UIColor buttonColor] forState:UIControlStateNormal];
    self.sendButton.layer.cornerRadius = 5.0f;
    self.sendButton.layer.masksToBounds = YES;
    self.sendButton.layer.borderWidth = 1.0f;
    self.sendButton.layer.borderColor= [[UIColor buttonColor]CGColor];

    self.barLabel.font = [UIFont systemFontOfSize:20];
    self.barLabel.textColor = [UIColor accentColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor navBarColor];
    self.navigationController.navigationBar.alpha = 1.0;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"river"]];

    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 120, 33)];
    label.numberOfLines = 2;
    label.text = @"Find\nPubChatters";
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:13];
    [self.findPubChattersButton addSubview:label];
    label.textColor = [UIColor buttonColor];
    self.findPubChattersButton.backgroundColor = [[UIColor backgroundColor] colorWithAlphaComponent:0.9];
    self.findPubChattersButton.layer.cornerRadius = 5.0f;
    self.findPubChattersButton.layer.masksToBounds = YES;
    self.findPubChattersButton.layer.borderWidth = 1.0f;
    self.findPubChattersButton.layer.borderColor= [[UIColor buttonColor]CGColor];


}
@end
