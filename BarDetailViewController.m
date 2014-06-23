//
//  BarDetailViewController.m
//  PubChatter
//
//  Created by David Warner on 6/16/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import "BarDetailViewController.h"
#import "BarWebpageViewController.h"
#import "Bar.h"
#import "Rating.h"
#import <Parse/Parse.h>

@interface BarDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *barNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *barAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceFromUserLabel;
@property (weak, nonatomic) IBOutlet UIImageView *barImageView;
@property (weak, nonatomic) IBOutlet UIImageView *ratingImageView;
@property (weak, nonatomic) IBOutlet UIButton *goToWebsiteButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *telephoneOutlet;
@property (weak, nonatomic) IBOutlet UITextView *aboutBarTextView;
@property (weak, nonatomic) IBOutlet UILabel *categoriesLabel;
@property (weak, nonatomic) IBOutlet UILabel *pubChattersCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *ratioLabel;
@property (weak, nonatomic) IBOutlet UILabel *barRatingLabel;
@property Bar *bar;


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
}

-(void)viewDidAppear:(BOOL)animated
{
    PFQuery *query = [PFQuery queryWithClassName:@"Bar"];
    [query whereKey:@"yelpID" equalTo:self.barFromSourceVC.yelpID];
    [query includeKey:@"usersInBar"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects) {
            NSArray *array = [[objects firstObject] objectForKey:@"usersInBar"];
            NSInteger pubChattersInBar = array.count;
            self.pubChattersCountLabel.text = [NSString stringWithFormat:@"%lu pubChatters in %@", (long)pubChattersInBar, self.barFromSourceVC.name];
            NSMutableArray *menInBar = [[NSMutableArray alloc] init];
            for (PFObject *object in array) {
                if ([[object objectForKey:@"gender"] isEqualToNumber:@1]) {
                    [menInBar addObject:object];
                }
            }
            NSInteger malePubChattersInBar = menInBar.count;
            NSInteger femalePubChattersInBar = pubChattersInBar - malePubChattersInBar;
            if (pubChattersInBar > 0) {
                CGFloat maleRatio = malePubChattersInBar/pubChattersInBar;
                CGFloat femaleRatio = femalePubChattersInBar/pubChattersInBar;
            self.ratioLabel.text = [NSString stringWithFormat:@"%.0f percent men  %.0f percent women", maleRatio *100, femaleRatio *100];
            NSLog(@"%lu", (unsigned long)menInBar.count);
            }
        }
    }];

    PFQuery *query2 = [PFQuery queryWithClassName:@"Bar"];
    [query2 whereKey:@"yelpID" equalTo:self.barFromSourceVC.yelpID];
    [query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects) {
            self.bar = [objects firstObject];
            NSLog(@"%@", self.bar);
            [self getRating];
        }
    }];
}


- (IBAction)onTelephoneButtonPressed:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@", self.barFromSourceVC.telephone]]];
}
- (IBAction)onRefreshButtonPushed:(id)sender
{
    PFQuery *query = [PFQuery queryWithClassName:@"Bar"];
    [query whereKey:@"yelpID" equalTo:self.barFromSourceVC.yelpID];
    [query includeKey:@"usersInBar"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (![objects isEqual:nil]) {
            NSArray *array = [[objects firstObject] objectForKey:@"usersInBar"];
            self.pubChattersCountLabel.text = [NSString stringWithFormat:@"%lu pubChatters in %@", (unsigned long)array.count, self.barFromSourceVC.name];
        }
    }];
}

-(void)getRating
{
    PFQuery *query = [PFQuery queryWithClassName:@"Rating"];
    [query includeKey:@"bar"];
    [query whereKey:@"bar" equalTo:self.bar];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

        NSInteger count = objects.count;
        NSInteger total = 0;
        for (PFObject *object in objects) {
            NSInteger number =  [[object valueForKey:@"rating"] intValue];
            total += number;
        }
            if (count > 0) {
                self.barRatingLabel.text = [NSString stringWithFormat:@"%ld", total/count];
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

@end
