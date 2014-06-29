//
//  LeftSideSlideOutTableViewController.m
//  PubChatter
//
//  Created by Richard Fellure on 6/24/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import "LeftSideSlideOutTableViewController.h"
#import "ChatBoxViewController.h"
#import "AppDelegate.h"
#import "ListOfUsersTableViewCell.h"
#import "OPPViewController.h"
#import "SWRevealViewController.h"
#import "UIColor+DesignColors.h"

#import <Parse/Parse.h>

@interface LeftSideSlideOutTableViewController ()

@property AppDelegate *appDelegate;
@property NSMutableArray *cellArray;
@property NSMutableArray *users;
@property NSArray *parseUsers;
@property NSDictionary *userSendingInvitation;
@property UIButton *selectedChatButton;

@end

@implementation LeftSideSlideOutTableViewController

- (void)viewDidLoad
{

    [super viewDidLoad];
    self.navigationController.navigationBar.backgroundColor = [UIColor navBarColor];
    self.navigationController.navigationBar.alpha = 1.0;
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    self.users = [NSMutableArray array];

    self.cellArray = [NSMutableArray array];

    [self.appDelegate.mcManager startBrowsingForPeers];

    if ([PFUser currentUser])
    {

    }

    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(peerDidChangeStateWithNotification:) name:@"MCDidChangeStateNotification"
                                              object:nil];

    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(receivedNotificationOfUserAdvertising:)
                                                name:@"MCFoundAdvertisingPeer"
                                              object:nil];

    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(peerStoppedAdvertising:)
                                                name:@"MCPeerStopAdvertising"
                                              object:nil];

    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(receivedInvitationForConnection:) name:@"MCReceivedInvitation"
                                              object:nil];

    self.tableView.backgroundColor = [UIColor whiteColor];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.users.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ListOfUsersTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSDictionary *dictionary = [self.users objectAtIndex:indexPath.row];

    MCPeerID *peerID = [dictionary objectForKey:@"peerID"];

    PFUser *user = [dictionary objectForKey:@"user"];

    cell.userNameLabel.textColor = [UIColor nameColor];
    cell.userAgeLabel.textColor = [UIColor whiteColor];
    cell.genderLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor clearColor];
    cell.chatButton.backgroundColor = [UIColor buttonColor];
    cell.chatButton.titleLabel.textColor = [UIColor whiteColor];
    cell.backgroundLabel.backgroundColor = [UIColor cellBackgroundColor];

    cell.userNameLabel.text = [user objectForKey:@"name"];
    cell.chatButton.tag = indexPath.row;
    [self.cellArray addObject:cell];
    cell.tag = [self.users indexOfObject:dictionary];
    cell.cellUserDisplayName = peerID.displayName;
    [cell.chatButton setTitle:@"Invite" forState:UIControlStateNormal];

    cell.chatButton.layer.masksToBounds = YES;
    cell.chatButton.layer.cornerRadius = 5.0f;
    cell.chatButton.layer.borderWidth = 1.0f;
    cell.chatButton.layer.borderColor = [[UIColor blackColor]CGColor];

    cell.backgroundLabel.layer.masksToBounds = YES;
    cell.backgroundLabel.layer.cornerRadius = 5.0f;
    cell.backgroundLabel.layer.borderWidth = 1.0f;
    cell.backgroundLabel.layer.borderColor = [[UIColor blackColor]CGColor];
    

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([user objectForKey:@"age"])
    {
        cell.userAgeLabel.text = [NSString stringWithFormat:@"%@",[user objectForKey:@"age"]];
    }
    else
    {
        cell.userAgeLabel.text = @"";
    }

    if ([user [@"gender"] isEqual:@0])
    {
        cell.genderLabel.text = @"F";
    }
    else if ([user[@"gender"] isEqual:@1])
    {
        cell.genderLabel.text = @"M";
    }
    else if ([user [@"gender"] isEqual:@2])
    {
        cell.genderLabel.text = @"Other";
        [cell.genderLabel sizeToFit];
    }
    else
    {
        cell.genderLabel.text = @"";
    }

    PFFile *imageFile = [user objectForKey:@"picture"];
    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
//        cell.userImage.layer.cornerRadius = cell.userImage.bounds.size.width /2.0;
        cell.userImage.layer.masksToBounds = YES;
        cell.userImage.layer.cornerRadius = 5.0f;
        cell.userImage.layer.borderWidth = 1.0f;
        cell.userImage.layer.borderColor = [[UIColor blackColor]CGColor];
        cell.userImage.image = [UIImage imageWithData:data];
    }];
    return cell;
}

#pragma mark - Hadling new advertising user

-(void)receivedNotificationOfUserAdvertising:(NSNotification *)notification
{
    MCPeerID *peerID = [[notification userInfo]objectForKey:@"peerID"];

    if (!self.parseUsers)
    {

        PFQuery *query = [PFQuery queryWithClassName:@"_User"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            if (!error)
            {
                self.parseUsers = [NSArray arrayWithArray:objects];
            }
            [self findUsers:peerID];

            [self.tableView reloadData];
        }];
    }
    else
    {
        [self findUsers: peerID];

        [self.tableView reloadData];
    }
}

# pragma mark - Finding active users

-(void)findUsers:(MCPeerID *)peerID
{
    for (NSDictionary *dictionary in self.parseUsers)
    {
        if ([[dictionary objectForKey:@"username"] isEqual:peerID.displayName])
        {
            if (self.users.count < self.appDelegate.mcManager.advertisingUsers.count)
            {
                NSDictionary *userDictionary = @{@"peerID": peerID,
                                                 @"user": dictionary};
                [self.users addObject:userDictionary];
            }
        }
    }
}

#pragma mark - Action for Button sending invitation

- (IBAction)onButtonTappedSendInvitation:(id)sender
{
    UIButton *button = (UIButton *)sender;

    UITableViewCell *cell = (UITableViewCell *)[[[sender superview]superview]superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

    NSDictionary *dictionary = [self.users objectAtIndex:indexPath.row];
    MCPeerID *peerID = [dictionary objectForKey:@"peerID"];

    if ([button.titleLabel.text isEqual:@"Invite"])
    {
        [self.appDelegate.mcManager.browser invitePeer:peerID toSession:self.appDelegate.mcManager.session withContext:nil timeout:30];

        [button setTitle:@"Inviting" forState:UIControlStateNormal];
        [button setEnabled:NO];
    }

    if ([button.titleLabel.text isEqual:@"Chat"])
    {
        self.selectedChatButton.backgroundColor = [UIColor buttonColor];
        self.selectedChatButton = nil;
        [[NSNotificationCenter defaultCenter]postNotificationName:@"PeerToChatWith" object:nil userInfo:dictionary];
        button.backgroundColor = [UIColor nameColor];
        self.selectedChatButton = button;
    }
}

#pragma mark - Private method for handling the changing of peer's state

-(void)peerDidChangeStateWithNotification:(NSNotification *)notification
{
    MCPeerID *peerID = [[notification userInfo]objectForKey:@"peerID"];

    NSDictionary *userDictionary = [NSDictionary new];
    ListOfUsersTableViewCell *cell = [ListOfUsersTableViewCell new];

    for (NSDictionary *dictionary in self.users)
    {
        if ([[dictionary objectForKey:@"peerID"] isEqual:peerID])
        {
            userDictionary = dictionary;
        }
    }

    //    long index = [self.users indexOfObject:userDictionary];

    for (ListOfUsersTableViewCell *userCell in self.cellArray)
    {
        if ([userCell.cellUserDisplayName isEqual:peerID.displayName])
        {
            cell = userCell;
        }
    }

    if ([[[notification userInfo]objectForKey:@"state"]intValue] == MCSessionStateConnecting)
    {
        [cell.chatButton setTitle:@"Inviting" forState:UIControlStateNormal];
        [cell.chatButton setEnabled:NO];
    }
    else if ([[[notification userInfo]objectForKey:@"state"]intValue] != MCSessionStateConnecting)
    {
        if ([[[notification userInfo]objectForKey:@"state"]intValue] == MCSessionStateConnected)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [cell.chatButton setEnabled:YES];
                [cell.chatButton setTitle:@"Chat" forState:UIControlStateNormal];
            });
        }
        if ([[[notification userInfo]objectForKey:@"state"]intValue] == MCSessionStateNotConnected)
        {
            if ([cell.chatButton.titleLabel.text isEqual: @"Connecting"])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [cell.chatButton setTitle:@"Declined" forState:UIControlStateNormal];
                    [cell.chatButton setEnabled:NO];
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [cell.chatButton setTitle:@"Invite" forState:UIControlStateNormal];
                    [cell.chatButton setEnabled:YES];
                });
            }
        }
    }
}

# pragma mark - Stopped Advertising method catcher

-(void)peerStoppedAdvertising:(NSNotification *)notificaion
{
    MCPeerID *peerID = [[notificaion userInfo]objectForKey:@"peerID"];
    NSDictionary *userDictionary = [NSDictionary new];

    for (NSDictionary *dictionary in self.users)
    {
        if ([dictionary objectForKey:@"peerID"] == peerID)
        {
            userDictionary = dictionary;
        }
    }
    [self.users removeObject:userDictionary];
    [self.tableView reloadData];
}

#pragma mark - Private method for handling receiving an invitation

-(void)receivedInvitationForConnection:(NSNotification *)notification
{
    self.userSendingInvitation = nil;
    MCPeerID *peerID = [[notification userInfo]objectForKey:@"peerID"];

    for (NSDictionary *dictionary in self.users)
    {
        MCPeerID *peer = [dictionary objectForKey:@"peerID"];
        if ([peer.displayName isEqual:peerID.displayName])
        {
            self.userSendingInvitation = dictionary;


        }
    }

    PFUser *user = [self.userSendingInvitation objectForKey:@"user"];

    NSString *alertViewTitle = [NSString stringWithFormat:@"%@ wants to connect and chat with you", [user objectForKey:@"name"]];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:alertViewTitle message:nil delegate:self cancelButtonTitle:@"Decline" otherButtonTitles:@"Accept", nil];
    [alertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    BOOL accept = (buttonIndex != alertView.cancelButtonIndex);

    ListOfUsersTableViewCell *cell = [ListOfUsersTableViewCell new];

    MCPeerID *peerID = [self.userSendingInvitation objectForKey:@"peerID"];

    for (ListOfUsersTableViewCell *userCell in self.cellArray)
    {
        if ([userCell.cellUserDisplayName isEqual:peerID.displayName])
        {
            cell = userCell;
        }
    }
    if (accept)
    {
        void (^invitationHandler)(BOOL, MCSession *) = [self.appDelegate.mcManager.invitationHandlerArray objectAtIndex:0];
        invitationHandler(accept, self.appDelegate.mcManager.session);
        [cell.chatButton setTitle:@"Connecting" forState:UIControlStateNormal];
        cell.chatButton.backgroundColor = [UIColor buttonColor];
        [cell.chatButton setEnabled:NO];
    }
    else
    {
        void (^invitationHandler)(BOOL, MCSession *) = [self.appDelegate.mcManager.invitationHandlerArray objectAtIndex:0];
        invitationHandler(0, self.appDelegate.mcManager.session);
        [cell.chatButton setTitle:@"Declined" forState:UIControlStateNormal];
    }

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    OPPViewController *oppVC = segue.destinationViewController;
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
    NSDictionary *dictionary = [self.users objectAtIndex:indexPath.row];
    PFUser *selectedUser = [dictionary objectForKey:@"user"];
    
    oppVC.user = selectedUser;
}

@end