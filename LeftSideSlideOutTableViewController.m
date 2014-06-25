//
//  LeftSideSlideOutTableViewController.m
//  PubChatter
//
//  Created by Richard Fellure on 6/24/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import "LeftSideSlideOutTableViewController.h"
#import "ChatViewController.h"
#import "ChatBoxViewController.h"
#import "AppDelegate.h"
#import "ListOfUsersTableViewCell.h"
#import "OPPViewController.h"
#import <Parse/Parse.h>

@interface LeftSideSlideOutTableViewController ()

@property AppDelegate *appDelegate;
@property NSMutableArray *cellArray;
@property NSMutableArray *users;

@end

@implementation LeftSideSlideOutTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    self.users = [NSMutableArray array];
    self.cellArray = [NSMutableArray array];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(queryForUsers)
                                                name:@"MCDidChangeStateNotification"
                                              object:nil];
    if ([PFUser currentUser])
    {
        [self.appDelegate.mcManager setupPeerAndSessionWithDisplayName:[[PFUser currentUser]objectForKey:@"username"]];
        [self.appDelegate.mcManager advertiseSelf:YES];
        NSLog(@"username %@", [[PFUser currentUser]objectForKey:@"username"]);
    }

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(peerDidChangeStateWithNotification:) name:@"MCDidChangeStateNotification" object:nil];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(queryForUsers) name:@"MCFoundAdvertisingPeer" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(peerStoppedAdvertising:) name:@"MCPeerStopAdvertising" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receivedInvitationForConnection:) name:@"MCReceivedInvitation" object:nil];
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

    cell.userNameLabel.text = [user objectForKey:@"username"];
    cell.chatButton.tag = indexPath.row;
    [self.cellArray addObject:cell];
    cell.tag = [self.users indexOfObject:dictionary];

    if ([user objectForKey:@"age"]) {
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

#pragma mark - Query

-(void)queryForUsers
{
    [self.users removeAllObjects];

    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             NSArray *users = [[NSArray alloc]initWithArray:objects];
             for (MCPeerID *peerID in self.appDelegate.mcManager.advertisingUsers)
             {
                 for (PFUser *user in users)
                 {
                     if ([peerID.displayName isEqual:[user objectForKey:@"username"]])
                     {
                         NSDictionary *dictionary = @{@"peerID": peerID,
                                                      @"user": user};
                         if (self.users.count <= self.appDelegate.mcManager.advertisingUsers.count)
                         {
                             [self.users addObject:dictionary];
                         }
                     }
                 }
                 [self.tableView reloadData];
             }
         }
     }];
}

#pragma mark - Action for Button sending invitation

- (IBAction)onButtonTappedSendInvitation:(id)sender
{
    UIButton *button = (UIButton *)sender;

    UITableViewCell *cell = (UITableViewCell *)[[[sender superview]superview]superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

    NSDictionary *dictionary = [self.users objectAtIndex:indexPath.row];

    NSLog(@"user to send data too %@", dictionary);
    MCPeerID *peerID = [dictionary objectForKey:@"peerID"];

    [self.appDelegate.mcManager.browser invitePeer:peerID toSession:self.appDelegate.mcManager.session withContext:nil timeout:30];

    if ([button.titleLabel.text isEqual:@"Chat"])
    {
        ChatBoxViewController *chatBoxVC = [[ChatBoxViewController alloc]init];
        chatBoxVC.userDictionary = dictionary;

        [self presentViewController:chatBoxVC animated:YES completion:nil];
    }
}

#pragma mark - Private method for handling the changing of peer's state

-(void)peerDidChangeStateWithNotification:(NSNotification *)notification
{

    MCPeerID *peerID = [[notification userInfo]objectForKey:@"peerID"];
    NSLog(@"Changing state with notification 1");

    for (NSDictionary *dictionary in self.users)
    {
        if ([[dictionary objectForKey:@"peerID"] isEqual:peerID])
        {
            int index = [self.users indexOfObject:dictionary];

            for (ListOfUsersTableViewCell *userCell in self.cellArray)
            {
                if (userCell.tag == index)
                {
                    if ([[[notification userInfo]objectForKey:@"state"]intValue] == MCSessionStateConnected)
                    {
                        [userCell.chatButton setHighlighted:YES];
                    }
                }
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
    NSLog(@"need to remove %@", userDictionary);
    [self.tableView reloadData];
}

#pragma mark - Private method for handling receiving an invitation

-(void)receivedInvitationForConnection:(NSNotification *)notification
{
    MCPeerID *peerID = [[notification userInfo]objectForKey:@"peerID"];
    NSLog(@"peerID.displayName of sender %@", peerID.displayName);
    NSString *alertViewTitle = [NSString stringWithFormat:@"%@ wants to connect and chat with you", peerID.displayName];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:alertViewTitle message:nil delegate:self cancelButtonTitle:@"Decline" otherButtonTitles:@"Accept", nil];
    [alertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    BOOL accept = (buttonIndex != alertView.cancelButtonIndex);

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