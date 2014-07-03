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
#import "UIColor+DesignColors.h"

@interface BarDetailViewController () <UIScrollViewDelegate>
@property (strong, nonatomic)  UILabel *barNameLabel;
@property (strong, nonatomic)  UILabel *barAddressLabel;
@property (strong, nonatomic)  UILabel *distanceFromUserLabel;
@property (strong, nonatomic)  UIImageView *barImageView;
@property (strong, nonatomic)  UIImageView *ratingImageView;
@property (strong, nonatomic)  UIButton *goToWebsiteButtonOutlet;
@property (strong, nonatomic)  UIButton *telephoneOutlet;
@property (weak, nonatomic) IBOutlet UIButton *refreshButtonOutlet;
@property (strong, nonatomic)  UITextView *aboutBarTextView;
@property (strong, nonatomic)  UILabel *categoriesLabel;
@property (strong, nonatomic)  UILabel *pubChattersCountLabel;
@property (strong, nonatomic)  UILabel *ratioLabel;
@property (strong, nonatomic)  UILabel *barRatingLabel;
@property (strong, nonatomic)  UILabel *backgroundView;
@property (strong, nonatomic)  UILabel *imageEdge;
@property (strong, nonatomic)  UILabel *yelpReviewersSayLabel;


@property (strong, nonatomic)  UILabel *ratingViewEdge;
@property (strong, nonatomic)  UILabel *numberOfUsersInBarLabel;
@property (strong, nonatomic)  NSString *numberOfUsersInBarString;
@property (strong, nonatomic)  NSString *ratingString;
@property (strong, nonatomic)  UIView *ratingBackgroundView;

@property Bar *bar;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation BarDetailViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scrollView.delegate = self;
    self.view.backgroundColor = [UIColor clearColor];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setTintColor:[UIColor buttonColor]];
    [self.refreshButtonOutlet setTitleColor:[UIColor buttonColor] forState:UIControlStateHighlighted];
    [self.refreshButtonOutlet setTitleColor:[UIColor buttonColor] forState:UIControlStateSelected];
    [self.refreshButtonOutlet setTitleColor:[UIColor buttonColor] forState:UIControlStateNormal];

    [self.barNameLabel removeFromSuperview];
    [self.barAddressLabel removeFromSuperview];
    [self.distanceFromUserLabel removeFromSuperview];
    [self.barImageView removeFromSuperview];
    [self.ratingImageView removeFromSuperview];
    [self.goToWebsiteButtonOutlet removeFromSuperview];
    [self.telephoneOutlet removeFromSuperview];
    [self.aboutBarTextView removeFromSuperview];
    [self.categoriesLabel removeFromSuperview];
    [self.barRatingLabel removeFromSuperview];
    [self.ratioLabel removeFromSuperview];
    [self.backgroundView removeFromSuperview];
    [self.imageEdge removeFromSuperview];

    [self.numberOfUsersInBarLabel removeFromSuperview];
    [self.ratingBackgroundView removeFromSuperview];

    [self addViewsToScrollView];
    [self getNumberofUserInBar];

}

-(void)addViewsToScrollView {

    CGFloat textLabelsOffset = 10.0;

    //Add imageview
    self.barImageView = [[UIImageView alloc] init];
    self.barImageView.frame = CGRectMake(self.scrollView.frame.size.width - 130, textLabelsOffset, 120, 120);
    self.barImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.barFromSourceVC.businessImageURL]]];
    self.barImageView.layer.masksToBounds = YES;
    self.barImageView.layer.cornerRadius = 5.0f;
    [self.scrollView addSubview:self.barImageView];

    // Add image borderview
    self.imageEdge = [[UILabel alloc] init];
    self.imageEdge.frame = CGRectMake(self.scrollView.frame.size.width - 132, textLabelsOffset - 1, 122, 122);
    self.imageEdge.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:self.imageEdge];

    //Bar name label
        self.barNameLabel = [[UILabel alloc] init];
        self.barNameLabel.frame = CGRectMake(10 , textLabelsOffset, (self.scrollView.frame.size.width - self.barImageView.frame.size.width - 30) , 30);
        self.barNameLabel.text = self.barFromSourceVC.name;
        [self.barNameLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:17]];
        self.barNameLabel.textAlignment = NSTextAlignmentLeft;
        self.barNameLabel.numberOfLines = 0;
        [self.barNameLabel sizeToFit];
        self.barNameLabel.textColor = [UIColor nameColor];
        [self.scrollView addSubview:self.barNameLabel];

    textLabelsOffset = textLabelsOffset + self.barNameLabel.frame.size.height + 5;

        self.barAddressLabel = [[UILabel alloc] init];
        self.barAddressLabel.frame = CGRectMake(10, textLabelsOffset, (self.scrollView.frame.size.width - self.barImageView.frame.size.width - 30), 30);
        self.barAddressLabel.text = self.barFromSourceVC.address;
        [self.barAddressLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:12]];
        self.barAddressLabel.textAlignment = NSTextAlignmentLeft;
        self.barAddressLabel.numberOfLines = 0;
        [self.barAddressLabel sizeToFit];
        self.barAddressLabel.textColor = [UIColor whiteColor];
        [self.scrollView addSubview:self.barAddressLabel];

    textLabelsOffset = textLabelsOffset + self.barAddressLabel.frame.size.height + 5;

        self.distanceFromUserLabel = [[UILabel alloc] init];
        self.distanceFromUserLabel.frame = CGRectMake(10, textLabelsOffset, (self.scrollView.frame.size.width - self.barImageView.frame.size.width - 30), 30);
        self.distanceFromUserLabel.text = [NSString stringWithFormat:@"%.02f miles", self.barFromSourceVC.distanceFromUser * 0.000621371];
        [self.distanceFromUserLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:12]];
        self.distanceFromUserLabel.textAlignment = NSTextAlignmentLeft;
        self.distanceFromUserLabel.numberOfLines = 0;
        [self.distanceFromUserLabel sizeToFit];
        self.distanceFromUserLabel.textColor = [UIColor whiteColor];
        [self.scrollView addSubview:self.distanceFromUserLabel];

    textLabelsOffset = textLabelsOffset + self.distanceFromUserLabel.frame.size.height + 10;

        self.telephoneOutlet = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.telephoneOutlet addTarget:self
               action:@selector(onTelephoneButtonPressed:)
     forControlEvents:UIControlEventTouchUpInside];
        [self.telephoneOutlet setTitle:[NSString stringWithFormat:@"(%@) %@-%@", [self.barFromSourceVC.telephone substringWithRange:NSMakeRange(0, 3)], [self.barFromSourceVC.telephone substringWithRange:NSMakeRange(3, 3)], [self.barFromSourceVC.telephone substringWithRange:NSMakeRange(6, 4)]] forState:UIControlStateNormal];
        self.telephoneOutlet.frame = CGRectMake(10, textLabelsOffset, (self.scrollView.frame.size.width - self.barImageView.frame.size.width - 30), 30);
        [self.telephoneOutlet setTitleColor:[UIColor buttonColor] forState:UIControlStateNormal];
 //       [self.telephoneOutlet setTitleColor:[UIColor whiteColor] forState:uicontrolstat];


        self.telephoneOutlet.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self.scrollView addSubview:self.telephoneOutlet];

    textLabelsOffset = textLabelsOffset + self.telephoneOutlet.frame.size.height + 10;

    self.goToWebsiteButtonOutlet = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.goToWebsiteButtonOutlet addTarget:self
                             action:@selector(seeOnYelp:)
                   forControlEvents:UIControlEventTouchUpInside];
    [self.goToWebsiteButtonOutlet setTitle:[NSString stringWithFormat:@"See %@ on Yelp", self.barFromSourceVC.name] forState:UIControlStateNormal];
    self.goToWebsiteButtonOutlet.frame = CGRectMake(10, textLabelsOffset, (self.scrollView.frame.size.width - 20), 30);
    [self.goToWebsiteButtonOutlet setTitleColor:[UIColor buttonColor] forState:UIControlStateNormal];
    [self.goToWebsiteButtonOutlet setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    self.goToWebsiteButtonOutlet.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.scrollView addSubview:self.goToWebsiteButtonOutlet];

    textLabelsOffset = textLabelsOffset + self.goToWebsiteButtonOutlet.frame.size.height + 10;

    self.categoriesLabel = [[UILabel alloc] init];
    self.categoriesLabel.frame = CGRectMake(10, textLabelsOffset, (self.scrollView.frame.size.width - 20), 30);
    self.categoriesLabel.text = [NSString stringWithFormat:@"Category:  %@\nOffers:  %@", self.barFromSourceVC.categories, self.barFromSourceVC.offers];
    [self.categoriesLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:12]];
    self.categoriesLabel.textAlignment = NSTextAlignmentLeft;
    self.categoriesLabel.numberOfLines = 0;
    [self.categoriesLabel sizeToFit];
    self.categoriesLabel.textColor = [UIColor whiteColor];
    [self.scrollView addSubview:self.categoriesLabel];

    textLabelsOffset = textLabelsOffset + self.categoriesLabel.frame.size.height + 10;

    self.yelpReviewersSayLabel = [[UILabel alloc] init];
    self.yelpReviewersSayLabel.frame = CGRectMake(10, textLabelsOffset, (self.scrollView.frame.size.width - 20), 30);
    self.yelpReviewersSayLabel.text = @"Yelp reviewers are saying...";
    [self.yelpReviewersSayLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12]];
    self.yelpReviewersSayLabel.textAlignment = NSTextAlignmentLeft;
    self.yelpReviewersSayLabel.numberOfLines = 0;
    [self.yelpReviewersSayLabel sizeToFit];
    self.yelpReviewersSayLabel.textColor = [UIColor whiteColor];
    [self.scrollView addSubview:self.yelpReviewersSayLabel];

    textLabelsOffset = textLabelsOffset + self.yelpReviewersSayLabel.frame.size.height;

    //Add Yelp user comments textview.
    self.aboutBarTextView = [[UITextView alloc] init];
    self.aboutBarTextView.frame = CGRectMake(10, textLabelsOffset, (self.scrollView.frame.size.width - 20), 70);
    self.aboutBarTextView.text = self.barFromSourceVC.aboutBusiness;
    self.aboutBarTextView.editable = NO;
    self.aboutBarTextView.textAlignment = NSTextAlignmentLeft;
    self.aboutBarTextView.textColor = [UIColor whiteColor];
    self.aboutBarTextView.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:self.aboutBarTextView];

    textLabelsOffset = textLabelsOffset + self.aboutBarTextView.frame.size.height + 10;

    //Add background view
    self.backgroundView = [[UILabel alloc] init];
    self.backgroundView.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, textLabelsOffset);
    self.backgroundView.backgroundColor = [UIColor clearColor];
    self.backgroundView.layer.cornerRadius = 5.0f;
    [self.scrollView insertSubview:self.backgroundView atIndex:0];

    self.scrollView.contentMode = UIViewContentModeScaleAspectFit;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, textLabelsOffset);

//    [self setStyle];
}

-(void)setPubChatInfoLabel
{
    CGFloat verticalOffset = 0.0;

    // Set background view look
    self.ratingBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(15, 73, 290, 72)];
    self.ratingBackgroundView.backgroundColor = [UIColor clearColor];
    self.ratingBackgroundView.layer.cornerRadius = 5.0f;
    [self.view addSubview:self.ratingBackgroundView];

    // Set number of users in bar look.
    self.numberOfUsersInBarLabel = [[UILabel alloc] init];
    self.numberOfUsersInBarLabel.frame = CGRectMake((self.ratingBackgroundView.frame.size.width/2) - ((self.ratingBackgroundView.frame.size.width - 20)/2), verticalOffset, self.ratingBackgroundView.frame.size.width - 20, 30);
    [self.numberOfUsersInBarLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:20]];
    self.numberOfUsersInBarLabel.text = self.numberOfUsersInBarString;
    self.numberOfUsersInBarLabel.textAlignment = NSTextAlignmentCenter;
    self.numberOfUsersInBarLabel.numberOfLines = 0;
    [self.numberOfUsersInBarLabel sizeToFit];
    [self.numberOfUsersInBarLabel clipsToBounds];
    self.numberOfUsersInBarLabel.textColor = [UIColor whiteColor];
    [self.ratingBackgroundView addSubview:self.numberOfUsersInBarLabel];

    verticalOffset = verticalOffset + self.numberOfUsersInBarLabel.frame.size.height;

    // Set bar rating.
    self.barRatingLabel = [[UILabel alloc] init];
    self.barRatingLabel.frame = CGRectMake((self.ratingBackgroundView.frame.size.width/2) - ((self.ratingBackgroundView.frame.size.width - 20)/2), verticalOffset, self.ratingBackgroundView.frame.size.width - 20, 30);
    [self.barRatingLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16]];
    self.barRatingLabel.text = self.ratingString;
    self.barRatingLabel.textAlignment = NSTextAlignmentCenter;
    self.barRatingLabel.numberOfLines = 0;
    [self.barRatingLabel sizeThatFits:CGSizeZero];
    [self.barRatingLabel clipsToBounds];
    self.barRatingLabel.textColor = [UIColor whiteColor];
    [self.ratingBackgroundView addSubview:self.barRatingLabel];
}

- (void)onTelephoneButtonPressed:(id)sender
{
    self.telephoneOutlet.titleLabel.textColor = [UIColor whiteColor];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@", self.barFromSourceVC.telephone]]];
}

-(void)seeOnYelp:(id)sender
{
    [self performSegueWithIdentifier:@"websegue" sender:self];
}


- (IBAction)onRefreshButtonPushed:(id)sender
{
    [self getNumberofUserInBar];
}

-(void)getNumberofUserInBar
{
    NSLog(@"Performing query for number of users in bar");
    PFQuery *query = [PFQuery queryWithClassName:@"Bar"];
    [query whereKey:@"yelpID" equalTo:self.barFromSourceVC.yelpID];
    [query includeKey:@"usersInBar"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (![objects isEqual:nil]) {
            if (objects.count > 0) {
                NSArray *array = [[objects firstObject] objectForKey:@"usersInBar"];
                NSInteger pubChattersInBar = array.count;
                self.numberOfUsersInBarString = [NSString stringWithFormat:@"%ld PubChat users in %@", (long)pubChattersInBar, self.barFromSourceVC.name];
                NSLog(@"Chatters present");
            }

        else {
            self.numberOfUsersInBarString = [NSString stringWithFormat:@"No PubChat users in %@", self.barFromSourceVC.name];
            NSLog(@"No chatters present");
            }
        }
        else {
        self.numberOfUsersInBarString = [NSString stringWithFormat:@"No PubChat users in %@", self.barFromSourceVC.name];
            NSLog(@"Bar not found");
        }
        [self findBar];
    }];
}

-(void)findBar
{
    NSLog(@"Performing query to find the bar");
    PFQuery *query = [PFQuery queryWithClassName:@"Bar"];
    [query whereKey:@"yelpID" equalTo:self.barFromSourceVC.yelpID];
      [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
          if (objects.firstObject) {
              self.bar = objects.firstObject;
              NSLog(@"You are in %@", self.bar);
          }
          else {
              NSLog(@"This is not a PubChat bar");
          }
          [self getRating];
      }];
}

-(void)getRating
{
    NSLog(@"Performing rating query");
    if (self.bar) {
        NSLog(@"Where you are %@", self.bar);
    PFQuery *query = [PFQuery queryWithClassName:@"Rating"];
    [query includeKey:@"bar"];
    [query whereKey:@"bar" equalTo:self.bar];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects) {
            if (objects.count > 0) {
            NSInteger count = objects.count;
            NSInteger total = 0;
            for (PFObject *object in objects) {
                NSInteger number =  [[object valueForKey:@"rating"] intValue];
                total += number;
            }
            NSLog(@"There is at least one rating");
            self.ratingString = [NSString stringWithFormat:@"Pubchatter rating: %ld", total/count];
            NSLog(@"Rating: %ld", total/count);
            }

        else
        {
            self.ratingString = [NSString stringWithFormat:@"%@ has not been rated", self.bar];
            NSLog(@"%@ has not been rated", self.bar);
        }

        }
        else {
            self.ratingString = [NSString stringWithFormat:@"%@ has not been rated", self.bar];
        }
        [self setPubChatInfoLabel];
        }];
    }

    else {
        self.numberOfUsersInBarString = [NSString stringWithFormat:@"No PubChat users in %@", self.barFromSourceVC.name];
        self.ratingString = [NSString stringWithFormat:@"%@ has not been rated", self.barFromSourceVC.name];
        [self setPubChatInfoLabel];
    }
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
