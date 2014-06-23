//
//  ChatViewController.m
//  PubChatter
//
//  Created by David Warner on 6/13/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import "ChatViewController.h"
#import "ListOfUsersTableViewCell.h"
#import "OPPViewController.h"
#import "AppDelegate.h"
#import "ChatBoxViewController.h"

@interface ChatViewController ()<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray *userArray;
@property AppDelegate *appDelegate;
@property NSMutableArray *cellArray;

-(void)peerDidChangeStateWithNotification:(NSNotification *)notification;
-(void)receivedInvitationForConnection: (NSNotification *)notification;
-(void)peerStoppedAdvertising: (NSNotification *)notificaion;
@end

@implementation ChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.userArray = [NSMutableArray array];
    self.cellArray = [NSMutableArray array];

    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];

    if ([PFUser currentUser])
    {
        [self.appDelegate.mcManager setupPeerAndSessionWithDisplayName:[[PFUser currentUser]objectForKey:@"username"]];
        [self.appDelegate.mcManager advertiseSelf:YES];
    }

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(peerDidChangeStateWithNotification:) name:@"MCDidChangeStateNotification" object:nil];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(queryForUsers) name:@"MCFoundAdvertisingPeer" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(peerStoppedAdvertising:) name:@"MCPeerStopAdvertising" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receivedInvitationForConnection:) name:@"MCReceivedInvitation" object:nil];

}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - UITableViewDelegate/DataSource methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.userArray.count;
}

-(ListOfUsersTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ListOfUsersTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID"];
    NSDictionary *dictionary = [self.userArray objectAtIndex:indexPath.row];
    MCPeerID *peerID = [dictionary objectForKey:@"peerID"];
    PFUser *user = [dictionary objectForKey:@"user"];
    cell.userNameLabel.text = peerID.displayName;
    cell.chatButton.tag = indexPath.row;
    [self.cellArray addObject:cell];
    cell.tag = [self.userArray indexOfObject:dictionary];

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

#pragma mark - Query for users and Creation of array of advertising users

-(void)queryForUsers
{
    NSLog(@"meow? %@", self.appDelegate.mcManager.advertisingUsers);
    // this gets all users of the app
    [self.userArray removeAllObjects];
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
                         if (self.userArray.count <= self.appDelegate.mcManager.advertisingUsers.count) {
                             NSLog(@"adding users");
                             [self.userArray addObject:dictionary];
                         }
                         NSLog(@"self.userarray %@", self.userArray);
                     }
                 }
             }
             [self.tableView reloadData];
         }
     }];
}

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual:@"OPPSegue"])
    {
        OPPViewController *destinationVC = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDictionary *dictionary = [self.userArray objectAtIndex:indexPath.row];
        PFUser *user = [dictionary objectForKey:@"user"];

        destinationVC.user = user;
    }

    //    else if ([segue.identifier isEqual: @"ChatBoxSegue"])
    //    {
    //        ChatBoxViewController *chatBoxVC = segue.destinationViewController;
    //        UIButton *button = (UIButton *)sender;
    //        UITableViewCell *cell = (UITableViewCell *)[button superview];
    //        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    //    }
}

#pragma mark - Action for Button sending invitation

- (IBAction)onButtonTappedSendInvitation:(id)sender
{
    UIButton *button = (UIButton *)sender;

    UITableViewCell *cell = (UITableViewCell *)[button superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

    NSDictionary *dictionary = [self.userArray objectAtIndex:indexPath.row];
    MCPeerID *peerID = [dictionary objectForKey:@"peerID"];

    [self.appDelegate.mcManager.browser invitePeer:peerID toSession:self.appDelegate.mcManager.session withContext:nil timeout:30];
}

#pragma mark - Private method for handling the changing of peer's state

-(void)peerDidChangeStateWithNotification:(NSNotification *)notification
{

    MCPeerID *peerID = [[notification userInfo]objectForKey:@"peerID"];
    NSDictionary *userDictionary = [NSDictionary new];
    ListOfUsersTableViewCell *cell = [ListOfUsersTableViewCell new];

    for (NSDictionary *dictionary in self.userArray)
    {
        if ([[dictionary objectForKey:@"peerID"] isEqual:peerID])
        {
            userDictionary = dictionary;
        }
    }

    int index = [self.userArray indexOfObject:userDictionary];

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
        NSLog(@"connecting");
    }
    else if ([[[notification userInfo]objectForKey:@"state"]intValue] != MCSessionStateConnecting)
    {
        if ([[[notification userInfo]objectForKey:@"state"]intValue] == MCSessionStateConnected)
        {
            [cell.chatButton setTitle:@"Chat" forState:UIControlStateNormal];
            NSLog(@"connected");
        }
        if ([[[notification userInfo]objectForKey:@"state"]intValue] == MCSessionStateNotConnected)
        {
            [cell.chatButton setTitle:@"Reconnect" forState:UIControlStateNormal];
            NSLog(@"reconnect");
        }

    }


}

#pragma mark - Private method for handling receiving an invitation

-(void)receivedInvitationForConnection:(NSNotification *)notification
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"You have been invited to connect" message:nil delegate:self cancelButtonTitle:@"Decline" otherButtonTitles:@"Accept", nil];
    [alertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    BOOL accept = (buttonIndex != alertView.cancelButtonIndex);

    void (^invitationHandler)(BOOL, MCSession *) = [self.appDelegate.mcManager.invitationHandlerArray objectAtIndex:0];
    invitationHandler(accept, self.appDelegate.mcManager.session);
}

-(void)peerStoppedAdvertising:(NSNotification *)notificaion
{
    MCPeerID *peerID = [[notificaion userInfo]objectForKey:@"peerID"];
    NSDictionary *userDictionary = [NSDictionary new];

    for (NSDictionary *dictionary in self.userArray)
    {
        if ([dictionary objectForKey:@"peerID"] == peerID)
        {
            userDictionary = dictionary;
        }
    }

    [self.userArray removeObject:userDictionary];
    [self.tableView reloadData];
}


//-(void)queryForUsers
//{
//// this gets all users of the app
//    NSMutableArray *arrayToSort = [[NSMutableArray alloc]init];
//    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
//     [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
//    {
//        if (!error)
//        {
//            self.userArray = [[NSArray alloc]initWithArray:objects];
//            for (PFUser *user in self.userArray)
//            {
//                if (![[user objectId]isEqualToString:[[PFUser currentUser]objectId]]&& ![[user objectId]isEqualToString:@"w7p8xjoee1"]) //keeping currentUser and admin out of chat box
//                {
//                    if (fabsf([[[PFUser currentUser] objectForKey:@"age"]floatValue] - [[user objectForKey:@"age"] floatValue]) <=  1){
//                        NSDictionary *dictionary = @{@"ageDif": @1, @"parseUser": user};
//                        [arrayToSort addObject:dictionary];
//                    }
//                    else if(fabsf([[[PFUser currentUser] objectForKey:@"age"]floatValue] - [[user objectForKey:@"age"] floatValue]) < 2){
//                        NSDictionary *dictionary = @{@"ageDif": @2, @"parseUser": user};
//                        [arrayToSort addObject:dictionary];
//                    }
//                    else if(fabsf([[[PFUser currentUser] objectForKey:@"age"]floatValue] - [[user objectForKey:@"age"] floatValue]) < 3){
//                        NSDictionary *dictionary = @{@"ageDif": @3, @"parseUser": user};
//                        [arrayToSort addObject:dictionary];
//                    }
//                    else if(fabsf([[[PFUser currentUser] objectForKey:@"age"]floatValue] - [[user objectForKey:@"age"] floatValue]) < 5){
//                        NSDictionary *dictionary = @{@"ageDif": @5, @"parseUser": user};
//                        [arrayToSort addObject:dictionary];
//                    }
//                    else if(fabsf([[[PFUser currentUser] objectForKey:@"age"]floatValue] - [[user objectForKey:@"age"] floatValue]) < 10){
//                        NSDictionary *dictionary = @{@"ageDif": @10, @"parseUser": user};
//                        [arrayToSort addObject:dictionary];
//                    }
//                    else if(fabsf([[[PFUser currentUser] objectForKey:@"age"]floatValue] - [[user objectForKey:@"age"] floatValue]) < 15){
//                        NSDictionary *dictionary = @{@"ageDif": @15, @"parseUser": user};
//                        [arrayToSort addObject:dictionary];
//                    }
//                    else{
//                        NSDictionary *dictionary = @{@"ageDif": @100, @"parseUser": user};
//                        [arrayToSort addObject:dictionary];
//                    }
//                }
//            }
//            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey: @"ageDif" ascending: YES];
//            NSArray *sortedArray = [arrayToSort sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
//            NSMutableArray *newArrayOfUsers = [NSMutableArray array];
//            for (NSDictionary *dic in sortedArray) {
//                PFUser *user = [dic objectForKey:@"parseUser"];
//                [newArrayOfUsers addObject:user];
//            }
//            self.userArray = [NSArray arrayWithArray:newArrayOfUsers];
//            [self.tableView reloadData];
//        }
//    }];
//
//// this gets users in the current bar
//    if ([PFUser currentUser])
//    {
//        PFQuery *queryForBar = [PFQuery queryWithClassName:@"Bar"];
//        [queryForBar whereKey:@"usersInBar" equalTo:[PFUser currentUser]];
//        [queryForBar includeKey:@"usersInBar"];
//        [queryForBar findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//            PFObject *bar = [objects firstObject];
//            if (bar)
//            {
//                self.navigationItem.title = [bar objectForKey:@"barName"];
//                self.userArray = [[NSArray alloc]initWithArray:[bar objectForKey:@"usersInBar"]];
//                for (PFUser *user in self.userArray)
//                {
//                    if (![[user objectId]isEqualToString:[[PFUser currentUser]objectId]]&& ![[user objectId]isEqualToString:@"w7p8xjoee1"]) //keeping currentUser and admin out of chat box
//                    {
//                        if (fabsf([[[PFUser currentUser] objectForKey:@"age"]floatValue] - [[user objectForKey:@"age"] floatValue]) <=  1){
//                            NSDictionary *dictionary = @{@"ageDif": @1, @"parseUser": user};
//                            [arrayToSort addObject:dictionary];
//                        }
//                        else if(fabsf([[[PFUser currentUser] objectForKey:@"age"]floatValue] - [[user objectForKey:@"age"] floatValue]) < 2){
//                            NSDictionary *dictionary = @{@"ageDif": @2, @"parseUser": user};
//                            [arrayToSort addObject:dictionary];
//                        }
//                        else if(fabsf([[[PFUser currentUser] objectForKey:@"age"]floatValue] - [[user objectForKey:@"age"] floatValue]) < 3){
//                            NSDictionary *dictionary = @{@"ageDif": @3, @"parseUser": user};
//                            [arrayToSort addObject:dictionary];
//                        }
//                        else if(fabsf([[[PFUser currentUser] objectForKey:@"age"]floatValue] - [[user objectForKey:@"age"] floatValue]) < 5){
//                            NSDictionary *dictionary = @{@"ageDif": @5, @"parseUser": user};
//                            [arrayToSort addObject:dictionary];
//                        }
//                        else if(fabsf([[[PFUser currentUser] objectForKey:@"age"]floatValue] - [[user objectForKey:@"age"] floatValue]) < 10){
//                            NSDictionary *dictionary = @{@"ageDif": @10, @"parseUser": user};
//                            [arrayToSort addObject:dictionary];
//                        }
//                        else if(fabsf([[[PFUser currentUser] objectForKey:@"age"]floatValue] - [[user objectForKey:@"age"] floatValue]) < 15){
//                            NSDictionary *dictionary = @{@"ageDif": @15, @"parseUser": user};
//                            [arrayToSort addObject:dictionary];
//                        }
//                        else{
//                            NSDictionary *dictionary = @{@"ageDif": @100, @"parseUser": user};
//                            [arrayToSort addObject:dictionary];
//                        }
//                    }
//                }
//                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey: @"ageDif" ascending: YES];
//                NSArray *sortedArray = [arrayToSort sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
//                NSMutableArray *newArrayOfUsers = [NSMutableArray array];
//                for (NSDictionary *dic in sortedArray) {
//                    PFUser *user = [dic objectForKey:@"parseUser"];
//                    [newArrayOfUsers addObject:user];
//                }
//                self.userArray = [NSArray arrayWithArray:newArrayOfUsers];
//            }
//            else
//            {
//                self.navigationItem.title = @"PubChat";
////                self.userArray = [NSArray array];
//            }
//        }];
////            [self.tableView reloadData];
//    }
//
//}

@end
