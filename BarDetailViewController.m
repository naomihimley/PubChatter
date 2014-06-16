//
//  BarDetailViewController.m
//  PubChatter
//
//  Created by David Warner on 6/16/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import "BarDetailViewController.h"

@interface BarDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *barNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *barAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceFromUserLabel;
@property (weak, nonatomic) IBOutlet UILabel *telephoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *barWebsiteURL;
@property (weak, nonatomic) IBOutlet UIImageView *barImageView;
@property (weak, nonatomic) IBOutlet UIImageView *ratingImageView;

@end

@implementation BarDetailViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.barNameLabel.text = self.barFromSourceVC.name;
    self.barAddressLabel.text = self.barFromSourceVC.address;
    NSString *milesFromUser = [NSString stringWithFormat:@"%.02f miles", self.barFromSourceVC.distanceFromUser * 0.000621371];
    self.distanceFromUserLabel.text = milesFromUser;
    self.telephoneLabel.text = self.barFromSourceVC.telephone;
    self.barWebsiteURL.text = [NSString stringWithFormat:@"%@", self.barFromSourceVC.businessURL.description];
}



@end
