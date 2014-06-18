//
//  BarDetailViewController.m
//  PubChatter
//
//  Created by David Warner on 6/16/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import "BarDetailViewController.h"
#import "BarWebpageViewController.h"
#import <Parse/Parse.h>

@interface BarDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *barNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *barAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceFromUserLabel;
@property (weak, nonatomic) IBOutlet UILabel *telephoneLabel;
@property (weak, nonatomic) IBOutlet UIImageView *barImageView;
@property (weak, nonatomic) IBOutlet UIImageView *ratingImageView;
@property (weak, nonatomic) IBOutlet UIButton *goToWebsiteButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *telephoneOutlet;
@property (weak, nonatomic) IBOutlet UITextView *aboutBarTextView;
@property (weak, nonatomic) IBOutlet UILabel *categoriesLabel;
@property (weak, nonatomic) IBOutlet UILabel *pubChattersCountLabel;

@end

@implementation BarDetailViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.barNameLabel.text = self.barFromSourceVC.name;
    self.barAddressLabel.text = self.barFromSourceVC.address;
    self.aboutBarTextView.text = self.barFromSourceVC.aboutBusiness;
    self.aboutBarTextView.editable = NO;
    NSString *milesFromUser = [NSString stringWithFormat:@"%.02f miles", self.barFromSourceVC.distanceFromUser * 0.000621371];
    self.distanceFromUserLabel.text = milesFromUser;

    [self.telephoneOutlet setTitle:[NSString stringWithFormat:@"(%@) %@-%@", [self.barFromSourceVC.telephone substringWithRange:NSMakeRange(0, 3)], [self.barFromSourceVC.telephone substringWithRange:NSMakeRange(3, 3)], [self.barFromSourceVC.telephone substringWithRange:NSMakeRange(6, 4)]] forState:UIControlStateNormal];
    [self.goToWebsiteButtonOutlet setTitle:[NSString stringWithFormat:@"See %@ on Yelp", self.barFromSourceVC.name] forState:UIControlStateNormal];

    NSData *bizImageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.barFromSourceVC.businessImageURL]];
    self.barImageView.image = [UIImage imageWithData:bizImageData];

    NSData *ratingImageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.barFromSourceVC.businessRatingImageURL]];
    self.ratingImageView.image = [UIImage imageWithData:ratingImageData];

    self.categoriesLabel.text = [NSString stringWithFormat:@"Category: %@\nOffers: %@", [[self.barFromSourceVC.categories objectAtIndex:0] objectAtIndex:0], [[self.barFromSourceVC.categories objectAtIndex:1] objectAtIndex:0]];


    PFQuery *query = [PFQuery queryWithClassName:@"Bar"];
    [query whereKey:@"yelpID" equalTo:self.barFromSourceVC.yelpID];
    [query includeKey:@"usersInBar"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects) {
            NSArray *array = [[objects firstObject] objectForKey:@"usersInBar"];
            self.pubChattersCountLabel.text = [NSString stringWithFormat:@"%lu pubChatters in %@", (unsigned long)array.count, self.barFromSourceVC.name];
            NSLog(@"%lu", (unsigned long)array.count);
        }
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *mobileURLString = self.barFromSourceVC.businessMobileURL;
    NSString *businessURLString = self.barFromSourceVC.businessURL;
    NSString *name = self.barFromSourceVC.name;
    BarWebpageViewController *detailViewController = segue.destinationViewController;
    detailViewController.webURLFromSource = businessURLString;
    detailViewController.mobileURLFromSource = mobileURLString;
    detailViewController.placeNameFromSource = name;
}

- (IBAction)onTelephoneButtonPressed:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@", self.barFromSourceVC.telephone]]];
}

@end
