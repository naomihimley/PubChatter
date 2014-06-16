//
//  BarDetailViewController.m
//  PubChatter
//
//  Created by David Warner on 6/16/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import "BarDetailViewController.h"
#import "BarWebpageViewController.h"

@interface BarDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *barNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *barAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceFromUserLabel;
@property (weak, nonatomic) IBOutlet UILabel *telephoneLabel;
@property (weak, nonatomic) IBOutlet UIImageView *barImageView;
@property (weak, nonatomic) IBOutlet UIImageView *ratingImageView;
@property (weak, nonatomic) IBOutlet UIButton *goToWebsiteButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *telephoneOutlet;

@end

@implementation BarDetailViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.barNameLabel.text = self.barFromSourceVC.name;
    self.barAddressLabel.text = self.barFromSourceVC.address;
    NSString *milesFromUser = [NSString stringWithFormat:@"%.02f miles", self.barFromSourceVC.distanceFromUser * 0.000621371];
    self.distanceFromUserLabel.text = milesFromUser;

    NSString *telprefix = [self.barFromSourceVC.telephone substringWithRange:NSMakeRange(1, 3)];
    NSLog(@"%@", telprefix);
    NSString *telmiddle = [self.barFromSourceVC.telephone substringWithRange:NSMakeRange(4, 3)];
    NSLog(@"%@", telmiddle);
    NSString *telend = [self.barFromSourceVC.telephone substringWithRange:NSMakeRange(7, 4)];
    NSLog(@"%@", telend);

    [self.telephoneOutlet setTitle:[NSString stringWithFormat:@"(%@) %@-%@", telprefix, telmiddle, telend] forState:UIControlStateNormal];
    [self.goToWebsiteButtonOutlet setTitle:[NSString stringWithFormat:@"Go to %@ website", self.barFromSourceVC.name] forState:UIControlStateNormal];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSURL *url = self.barFromSourceVC.businessURL;
    NSString *name = self.barFromSourceVC.name;
    BarWebpageViewController *detailViewController = segue.destinationViewController;
    detailViewController.urlFromSource = url;
    detailViewController.placeNameFromSource = name;
}

- (IBAction)onGoToWebsiteButtonPressed:(id)sender
{
}

- (IBAction)onTelephoneButtonPressed:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@", self.barFromSourceVC.telephone]]];
}

@end
