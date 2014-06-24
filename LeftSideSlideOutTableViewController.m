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
#import <Parse/Parse.h>

@interface LeftSideSlideOutTableViewController ()

@property AppDelegate *appDelegate;
@property NSArray *users;

@end

@implementation LeftSideSlideOutTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    self.users = [NSArray array];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(queryForUsers)
                                                name:@"MCDidChangeStateNotification"
                                              object:nil];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSDictionary *dictionary = [self.users objectAtIndex:indexPath.row];

    PFUser *user = [dictionary objectForKey:@"user"];

    cell.textLabel.text = [user objectForKey:@"username"];

    return cell;
}

#pragma mark - Query

-(void)queryForUsers
{
    NSMutableArray *array = [NSMutableArray array];
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             NSArray *users = [[NSArray alloc]initWithArray:objects];
             for (MCPeerID *peerID in self.appDelegate.mcManager.session.connectedPeers)
             {
                 for (PFUser *user in users)
                 {
                     if ([peerID.displayName isEqual:[user objectForKey:@"username"]])
                     {
                         NSDictionary *dictionary = @{@"peerID": peerID,
                                                      @"user": user};
                         if (self.users.count <= self.appDelegate.mcManager.session.connectedPeers.count)
                         {
                             [array addObject:dictionary];
                         }
                     }
                 }
                 self.users = [NSArray arrayWithArray:array];
                 [self.tableView reloadData];
             }
         }
     }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ChatBoxViewController *chatBoxVC = segue.destinationViewController;
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];

    NSDictionary *dictionary = [self.users objectAtIndex:indexPath.row];

    chatBoxVC.userDictionary = dictionary;
}

@end