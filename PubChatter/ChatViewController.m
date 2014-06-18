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

@interface ChatViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSArray *userArray;

@end

@implementation ChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self queryForUsers];
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.userArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ListOfUsersTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID"];
    PFUser *user = [self.userArray objectAtIndex:indexPath.row];

    cell.userNameLabel.text = [user objectForKey:@"username"];

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
//will need to work out a query that only pulls the users that are within the bar
//-(void)queryForUsersInBar: (PFUser *)usersInLocation
//{
//    PFRelation *relation = [usersInLocation relationForKey:@"barUserIsIn"];
//    PFQuery *query = [relation query];
//}

-(void)queryForUsers
{
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            self.userArray = [[NSArray alloc]initWithArray:objects];
            [self.tableView reloadData];
        }
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    OPPViewController *destinationVC = segue.destinationViewController;

    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];

    destinationVC.user = [self.userArray objectAtIndex:indexPath.row];

}

@end
