//
//  ChatViewController.m
//  PubChatter
//
//  Created by David Warner on 6/13/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import "ChatViewController.h"
#import "ListOfUsersTableViewCell.h"
#import <Parse/Parse.h>
#import "OPPViewController.h"
#import "AppDelegate.h"

@interface ChatViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSArray *userArray;
@property AppDelegate *appDelegate;

-(void)peerStartedAdvertising;
@end

@implementation ChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];

    [self.appDelegate.mcManager setupPeerAndSessionWithDisplayName:[[PFUser currentUser]objectForKey:@"username"]];
    [self.appDelegate.mcManager advertiseSelf:YES];
    [self.appDelegate.mcManager setupMCBrowser];

//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(peerDidChangeStateWithNotification) name:@"MCDidChangeStateNotification" object:nil];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(peerStartedAdvertising) name:@"MCFoundAdvertisingPeer" object:nil];

}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self queryForUsers];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    return self.appDelegate.mcManager.advertisingUsersFromParse.count;
    return self.appDelegate.mcManager.advertisingUsers.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ListOfUsersTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID"];
    MCPeerID *peerID = [self.appDelegate.mcManager.advertisingUsers objectAtIndex:indexPath.row];
    cell.userNameLabel.text = peerID.displayName;
//    PFUser *user = [self.appDelegate.mcManager.advertisingUsersFromParse objectAtIndex:indexPath.row];
//    cell.userNameLabel.text = [[user objectForKey:@"user"]objectForKey:@"username"];
//    if ([[user objectForKey:@"user"]objectForKey:@"age"]) {
//        cell.userAgeLabel.text = [NSString stringWithFormat:@"%@",[[user objectForKey:@"user"]objectForKey:@"age"]];
//    }
//    else
//    {
//        cell.userAgeLabel.text = @"";
//    }

//    if ([user [@"gender"] isEqual:@0])
//    {
//        cell.genderLabel.text = @"F";
//    }
//    else if ([user[@"gender"] isEqual:@1])
//    {
//        cell.genderLabel.text = @"M";
//    }
//    else if ([user [@"gender"] isEqual:@2])
//    {
//        cell.genderLabel.text = @"Other";
//        [cell.genderLabel sizeToFit];
//    }
//    else
//    {
//        cell.genderLabel.text = @"";
//    }
//
//    PFFile *imageFile = [user objectForKey:@"picture"];
//    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
//        cell.userImage.image = [UIImage imageWithData:data];
//    }];
    return cell;
}
//
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





-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    OPPViewController *destinationVC = segue.destinationViewController;

    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];

//    destinationVC.user = [self.userArray objectAtIndex:indexPath.row];
}

- (IBAction)onButtonTappedSendInvitation:(id)sender
{
    
}

-(void)peerStartedAdvertising
{
    [self.tableView reloadData];
}


@end
