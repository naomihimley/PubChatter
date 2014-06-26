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
#import <Parse/Parse.h>

@interface LeftSideSlideOutTableViewController ()

@property AppDelegate *appDelegate;
@property NSMutableArray *cellArray;
@property NSMutableArray *users;
@property NSArray *parseUsers;
@property NSDictionary *userSendingInvitation;

@end

@implementation LeftSideSlideOutTableViewController

- (void)viewDidLoad
{

//    [self queryForUsers];

    [super viewDidLoad];
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    self.users = [NSMutableArray array];


    NSLog(@"self.users in viewDidLoad %@", self.users);
    self.cellArray = [NSMutableArray array];

    if ([PFUser currentUser])
    {
        [self.appDelegate.mcManager setupPeerAndSessionWithDisplayName:[[PFUser currentUser]objectForKey:@"username"]];
        [self.appDelegate.mcManager advertiseSelf:YES];
        NSLog(@"username %@", [[PFUser currentUser]objectForKey:@"username"]);
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

    self.tableView.backgroundColor = [UIColor grayColor];
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

    PFUser *user = [dictionary objectForKey:@"user"];

    cell.userNameLabel.textColor = [UIColor blueColor];
    cell.userAgeLabel.textColor = [UIColor blueColor];
    cell.genderLabel.textColor = [UIColor blueColor];
    cell.backgroundColor = [UIColor grayColor];

    cell.userNameLabel.text = [user objectForKey:@"name"];
    cell.chatButton.tag = indexPath.row;
    [self.cellArray addObject:cell];
    cell.tag = [self.users indexOfObject:dictionary];

    NSLog(@"cell.tag %i",cell.tag);

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
    }

    [button setTitle:@"Connecting" forState:UIControlStateNormal];
    [button setEnabled:NO];

    if ([button.titleLabel.text isEqual:@"Chat"])
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"PeerToChatWith" object:nil userInfo:dictionary];
        [self dismissViewControllerAnimated:YES completion:nil];
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

    int index = [self.users indexOfObject:userDictionary];

    for (ListOfUsersTableViewCell *userCell in self.cellArray)
    {
        if (userCell.tag == index)
        {
            cell = userCell;
        }
    }

    if ([[[notification userInfo]objectForKey:@"state"]intValue] == MCSessionStateConnecting)
    {
        [cell.chatButton setTitle:@"Connecting" forState:UIControlStateNormal];
        [cell.chatButton setEnabled:NO];
    }
    else if ([[[notification userInfo]objectForKey:@"state"]intValue] != MCSessionStateConnecting)
    {
        if ([[[notification userInfo]objectForKey:@"state"]intValue] == MCSessionStateConnected)
        {
            [cell.chatButton setEnabled:YES];
            [cell.chatButton setTitle:@"Chat" forState:UIControlStateNormal];

        }
        if ([[[notification userInfo]objectForKey:@"state"]intValue] == MCSessionStateNotConnected)
        {
            [cell.chatButton setTitle:@"Connect" forState:UIControlStateNormal];
            [cell.chatButton setEnabled:YES];
        }
    }
//    for (NSDictionary *dictionary in self.users)
//    {
//        if ([[dictionary objectForKey:@"peerID"] isEqual: peerID])
//        {
//            long index = [self.users indexOfObject:dictionary];
//
//            for (ListOfUsersTableViewCell *userCell in self.cellArray)
//            {
//                if (userCell.tag == index)
//                {
//                    if ([[[notification userInfo]objectForKey:@"state"]intValue] == MCSessionStateConnected)
//                    {
//                        NSLog(@"Dictionary %@", dictionary);
////                        [userCell.chatButton setHighlighted:YES];
//                        [userCell.chatButton setTitle:@"Chat" forState:UIControlStateNormal];
//                        [userCell.chatButton setEnabled:YES];
//                    }
//                }
//            }
//        }
//    }
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
            NSLog(@"peer to be removed %@", dictionary);
            userDictionary = dictionary;
        }
    }
    [self.users removeObject:userDictionary];
    NSLog(@"self.users after a user has stopped advertising %@", self.users);
    [self.tableView reloadData];
}

#pragma mark - Private method for handling receiving an invitation

-(void)receivedInvitationForConnection:(NSNotification *)notification
{
    MCPeerID *peerID = [[notification userInfo]objectForKey:@"peerID"];

    NSLog(@"peerID from notification before going into dictionary %@", peerID);
    NSDictionary *user = [NSDictionary new];

    for (NSDictionary *dictionary in self.users)
    { 
        if ([[dictionary objectForKey:@"peerID"] isEqual:peerID])
        {
            self.userSendingInvitation = dictionary;
        }
    }

    NSString *peerName = [[user objectForKey:@"user"]objectForKey:@"name"];
    NSString *alertViewTitle = [NSString stringWithFormat:@"%@ wants to connect and chat with you", peerName];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:alertViewTitle message:nil delegate:self cancelButtonTitle:@"Decline" otherButtonTitles:@"Accept", nil];
    [alertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    BOOL accept = (buttonIndex != alertView.cancelButtonIndex);

    ListOfUsersTableViewCell *cell = [ListOfUsersTableViewCell new];

    int index = [self.users indexOfObject:self.userSendingInvitation];

    for (ListOfUsersTableViewCell *userCell in self.cellArray)
    {
        if (userCell.tag == index)
        {
            cell = userCell;
        }
    }

    [cell.chatButton setTitle:@"Connecting" forState:UIControlStateNormal];
    [cell.chatButton setEnabled:NO];

    void (^invitationHandler)(BOOL, MCSession *) = [self.appDelegate.mcManager.invitationHandlerArray objectAtIndex:0];
    invitationHandler(accept, self.appDelegate.mcManager.session);
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