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

@interface ChatViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSArray *userArray;

@end

@implementation ChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ListOfUsersTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID"];
    PFUser *user = [self.userArray objectAtIndex:indexPath.row];

    cell.userNameLabel.text = [user objectForKey:@"username"];

    return cell;
}
//will need to work out a query that only pulls the users that are within the bar
//-(void)queryForUsersInBar: (PFUser *)usersInLocation
//{
//    PFRelation *relation = [usersInLocation relationForKey:@"barUserIsIn"];
//    PFQuery *query = [relation query];
//}

-(void)queryForUsers
{
    PFQuery *query = [PFQuery queryWithClassName:@"User"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            self.userArray = [[NSArray alloc]initWithArray:objects];
        }
        [self.tableView reloadData];
    }];
}

@end
