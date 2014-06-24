//
//  LeftSlideOutViewController.m
//  PubChatter
//
//  Created by Richard Fellure on 6/23/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import "LeftSlideOutViewController.h"
#import "ChatViewController.h"
#import "AppDelegate.h"

@interface LeftSlideOutViewController ()

@property AppDelegate *appDelegate;
@end

@implementation LeftSlideOutViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    self.users = [NSArray array];
    
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
                             [array addObject:dictionary];
                         }
                         NSLog(@"self.users %@", self.users);
                     }
                 }
                 self.users = [NSArray arrayWithArray:array];
                 [self.tableView reloadData];
             }
         }
     }];
}

@end
