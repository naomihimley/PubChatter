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
@property (weak, nonatomic) IBOutlet UILabel *ratioLabel;
@property (weak, nonatomic) IBOutlet UISlider *sliderOutlet;
@property (weak, nonatomic) IBOutlet UIButton *rateBarButtonOutlet;

@end

@implementation BarDetailViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.sliderOutlet.minimumValue = 0;
    self.sliderOutlet.minimumValue = 10;
    self.sliderOutlet.hidden = YES;
    self.rateBarButtonOutlet.hidden = YES;
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

    [self checkIfUserisInBar];
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
- (IBAction)onRateButtonPressed:(id)sender
{
    NSInteger rating = self.sliderOutlet.value;
    NSLog(@"%ld", (long)rating);
}

-(void)checkIfUserisInBar
{
    PFQuery *queryForBar = [PFQuery queryWithClassName:@"Bar"];
    [queryForBar whereKey:@"usersInBar" equalTo:[PFUser currentUser]];
    [queryForBar findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (![objects isEqual:nil]) {
            NSLog(@"%@", objects.firstObject);
            [self.rateBarButtonOutlet setTitle:[NSString stringWithFormat:@"Rate %@", self.barFromSourceVC.name] forState:UIControlStateNormal];
            self.rateBarButtonOutlet.hidden = NO;
            self.sliderOutlet.hidden = NO;
        }
        else
        {
            self.rateBarButtonOutlet.hidden = YES;
            self.sliderOutlet.hidden = YES;
        }
    }];
}

@end
