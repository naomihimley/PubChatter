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

@property UIButton *telephoneOutlet;
@property (strong, nonatomic)  NSString *numberOfUsersInBarString;

@property Bar *bar;
@property NSDictionary *broDictionary;
@property NSDictionary *artsyDictionary;
@property NSDictionary *chillDictionary;
@property NSDictionary *hipsterDictionary;
@property NSDictionary *classyDictionary;
@property NSDictionary *diveDictionary;
@property NSDictionary *clubbyDictionary;
@property NSArray *ratingsArray;
@property NSNumber *ratingsCount;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *refreshButtonOutlet;

@end

@implementation BarDetailViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scrollView.delegate = self;
    self.view.backgroundColor = [UIColor blackColor];
}

-(void)viewDidAppear:(BOOL)animated
{
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    [self.navigationController.navigationBar setTintColor:[UIColor buttonColor]];
    [self.refreshButtonOutlet setTitleColor:[UIColor buttonColor] forState:UIControlStateHighlighted];
    [self.refreshButtonOutlet setTitleColor:[UIColor buttonColor] forState:UIControlStateSelected];
    [self.refreshButtonOutlet setTitleColor:[UIColor buttonColor] forState:UIControlStateNormal];

    [self removeViews];
    [self getNumberofUserInBar];
}

-(void)removeViews
{
    for (UIView *subview in [self.scrollView subviews]) {
        [subview removeFromSuperview];
    }

    for (UILabel *sublabel in [self.scrollView subviews]) {
        [sublabel removeFromSuperview];
    }

    for (UIImageView *imageview in [self.scrollView subviews]) {
        [imageview removeFromSuperview];
    }

    for (UIButton *button in [self.scrollView subviews]) {
        [button removeFromSuperview];
    }
}


-(void)setViewContent
{
//    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
//    CGFloat navBarHeight = self.navigationController.navigationBar.frame.size.height;
//    CGFloat topOfView = statusBarHeight + navBarHeight;
    CGFloat verticalOffset = 0.0f;

    // Create number of users in bar label.
    UILabel *numberOfUsersInBarLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, 30)];
    [numberOfUsersInBarLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:15]];
    numberOfUsersInBarLabel.text = self.numberOfUsersInBarString;
    numberOfUsersInBarLabel.textAlignment = NSTextAlignmentCenter;
    numberOfUsersInBarLabel.numberOfLines = 0;
    //    [self.numberOfUsersInBarLabel sizeToFit];
    [numberOfUsersInBarLabel clipsToBounds];
    numberOfUsersInBarLabel.textColor = [UIColor whiteColor];
    numberOfUsersInBarLabel.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:numberOfUsersInBarLabel];

    verticalOffset = verticalOffset + numberOfUsersInBarLabel.frame.size.height;

    if (self.ratingsArray) {

    // Dynamically set bar widths to a fraction of the first bar width.
    CGFloat firstBarWidth = self.view.frame.size.width - 100;

    NSDictionary *firstDictionary = [self.ratingsArray objectAtIndex:0];
    NSNumber *firstDictionaryRatingCount = [firstDictionary objectForKey:@"Count"];
    CGFloat firstDictRatingFloat = firstDictionaryRatingCount.floatValue;

    NSDictionary *secondDictionary = [self.ratingsArray objectAtIndex:1];
    NSNumber *secondDictionaryRatingCount = [secondDictionary objectForKey:@"Count"];
    CGFloat secondDictRatingFloat = secondDictionaryRatingCount.floatValue;
    CGFloat secondBarWidth = (secondDictRatingFloat / firstDictRatingFloat) * firstBarWidth;

    NSDictionary *thirdDictionary = [self.ratingsArray objectAtIndex:2];
    NSNumber *thirdDictionaryRatingCount = [thirdDictionary objectForKey:@"Count"];
    CGFloat thirdDictRatingFloat = thirdDictionaryRatingCount.floatValue;
    CGFloat thirdBarWidth = (thirdDictRatingFloat / firstDictRatingFloat) * firstBarWidth;

    NSDictionary *fourthDictionary = [self.ratingsArray objectAtIndex:3];
    NSNumber *fourthDictionaryRatingCount = [fourthDictionary objectForKey:@"Count"];
    CGFloat fourthDictRatingFloat = fourthDictionaryRatingCount.floatValue;
    CGFloat fourthBarWidth = (fourthDictRatingFloat / firstDictRatingFloat) * firstBarWidth;

    NSDictionary *fifthDictionary = [self.ratingsArray objectAtIndex:4];
    NSNumber *fifthDictionaryRatingCount = [fifthDictionary objectForKey:@"Count"];
    CGFloat fifthDictRatingFloat = fifthDictionaryRatingCount.floatValue;
    CGFloat fifthBarWidth = (fifthDictRatingFloat / firstDictRatingFloat) * firstBarWidth;

    NSDictionary *sixthDictionary = [self.ratingsArray objectAtIndex:5];
    NSNumber *sixthDictionaryRatingCount = [sixthDictionary objectForKey:@"Count"];
    CGFloat sixthDictRatingFloat = sixthDictionaryRatingCount.floatValue;
    CGFloat sixthBarWidth = (sixthDictRatingFloat / firstDictRatingFloat) * firstBarWidth;

    NSDictionary *seventhDictionary = [self.ratingsArray objectAtIndex:6];
    NSNumber *seventhDictionaryRatingCount = [seventhDictionary objectForKey:@"Count"];
    CGFloat seventhDictRatingFloat = seventhDictionaryRatingCount.floatValue;
    CGFloat seventhBarWidth = (seventhDictRatingFloat / firstDictRatingFloat) * firstBarWidth;

    CGFloat barheight = 30.0f;

    NSMutableArray *barViewsArray = [NSMutableArray new];
    NSMutableArray *barLabelsArray = [NSMutableArray new];

    // Create first bar and label
    UIView *firstBar = [[UIView alloc] init];
    firstBar.frame = CGRectMake(self.view.frame.origin.x, verticalOffset, firstBarWidth, barheight);
    [barViewsArray addObject:firstBar];
    UILabel *firstBarLabel = [[UILabel alloc] init];
    firstBarLabel.frame = CGRectMake(self.view.frame.origin.x + firstBar.frame.size.width, verticalOffset, self.view.frame.size.width - firstBar.frame.size.width, barheight);
    firstBarLabel.text = [NSString stringWithFormat:@"  %@: %@", [firstDictionary objectForKey:@"userRating"], [firstDictionary objectForKey:@"Count"]];
    [barLabelsArray addObject:firstBarLabel];
    verticalOffset = verticalOffset + firstBarLabel.frame.size.height;

    // Create second bar and label
    UIView *secondBar = [[UIView alloc] init];
    secondBar.frame = CGRectMake(self.view.frame.origin.x, verticalOffset, secondBarWidth, barheight);
    [barViewsArray addObject:secondBar];
    UILabel *secondBarLabel = [[UILabel alloc] init];
    secondBarLabel.frame = CGRectMake(self.view.frame.origin.x + secondBar.frame.size.width, verticalOffset, self.view.frame.size.width - secondBar.frame.size.width, barheight);
    secondBarLabel.text = [NSString stringWithFormat:@"  %@: %@", [secondDictionary objectForKey:@"userRating"], [secondDictionary objectForKey:@"Count"]];
    [barLabelsArray addObject:secondBarLabel];
    verticalOffset = verticalOffset + secondBarLabel.frame.size.height;

    // Create third bar and label
    UIView *thirdBar = [[UIView alloc] init];
    thirdBar.frame = CGRectMake(self.view.frame.origin.x, verticalOffset, thirdBarWidth, barheight);
    [barViewsArray addObject:thirdBar];
    UILabel *thirdBarLabel = [[UILabel alloc] init];
    thirdBarLabel.frame = CGRectMake(self.view.frame.origin.x + thirdBar.frame.size.width, verticalOffset, self.view.frame.size.width - thirdBar.frame.size.width, barheight);
    thirdBarLabel.text = [NSString stringWithFormat:@"  %@: %@", [thirdDictionary objectForKey:@"userRating"], [thirdDictionary objectForKey:@"Count"]];
    [barLabelsArray addObject:thirdBarLabel];
    verticalOffset = verticalOffset + thirdBarLabel.frame.size.height;

    // Create fourth bar and label
    UIView *fourthBar = [[UIView alloc] init];
    fourthBar.frame = CGRectMake(self.view.frame.origin.x, verticalOffset, fourthBarWidth, barheight);
    [barViewsArray addObject:fourthBar];
    UILabel *fourthBarLabel = [[UILabel alloc] init];
    fourthBarLabel.frame = CGRectMake(self.view.frame.origin.x + fourthBar.frame.size.width, verticalOffset, self.view.frame.size.width - fourthBar.frame.size.width, barheight);
    fourthBarLabel.text = [NSString stringWithFormat:@"  %@: %@", [fourthDictionary objectForKey:@"userRating"], [fourthDictionary objectForKey:@"Count"]];
    [barLabelsArray addObject:fourthBarLabel];
    verticalOffset = verticalOffset + fourthBarLabel.frame.size.height;

    // Create fifth bar and label
    UIView *fifthBar = [[UIView alloc] init];
    fifthBar.frame = CGRectMake(self.view.frame.origin.x, verticalOffset, fifthBarWidth, barheight);
    [barViewsArray addObject:fifthBar];
    UILabel *fifthBarLabel = [[UILabel alloc] init];
    fifthBarLabel.frame = CGRectMake(self.view.frame.origin.x + fifthBar.frame.size.width, verticalOffset, self.view.frame.size.width - fifthBar.frame.size.width, barheight);
    fifthBarLabel.text = [NSString stringWithFormat:@"  %@: %@", [fifthDictionary objectForKey:@"userRating"], [fifthDictionary objectForKey:@"Count"]];
    [barLabelsArray addObject:fifthBarLabel];
    verticalOffset = verticalOffset + fifthBarLabel.frame.size.height;

    // Create sixth bar and label
    UIView *sixthBar = [[UIView alloc] init];
    sixthBar.frame = CGRectMake(self.view.frame.origin.x, verticalOffset, sixthBarWidth, barheight);
    [barViewsArray addObject:sixthBar];
    UILabel *sixthBarLabel = [[UILabel alloc] init];
    sixthBarLabel.frame = CGRectMake(self.view.frame.origin.x + sixthBar.frame.size.width, verticalOffset, self.view.frame.size.width - sixthBar.frame.size.width, barheight);
    sixthBarLabel.text = [NSString stringWithFormat:@"  %@: %@", [sixthDictionary objectForKey:@"userRating"], [sixthDictionary objectForKey:@"Count"]];
    [barLabelsArray addObject:sixthBarLabel];
    verticalOffset = verticalOffset + sixthBarLabel.frame.size.height;

    // Create seventh bar and label
    UIView *seventhBar = [[UIView alloc] init];
    seventhBar.frame = CGRectMake(self.view.frame.origin.x, verticalOffset, seventhBarWidth, barheight);
    [barViewsArray addObject:seventhBar];
    UILabel *seventhBarLabel = [[UILabel alloc] init];
    seventhBarLabel.frame = CGRectMake(self.view.frame.origin.x + seventhBar.frame.size.width, verticalOffset, self.view.frame.size.width - seventhBar.frame.size.width, barheight);
    seventhBarLabel.text = [NSString stringWithFormat:@"  %@: %@", [seventhDictionary objectForKey:@"userRating"], [seventhDictionary objectForKey:@"Count"]];
    [barLabelsArray addObject:seventhBarLabel];
    verticalOffset = verticalOffset + seventhBarLabel.frame.size.height;

    for (UIView *view in barViewsArray) {
        view.backgroundColor = [UIColor buttonColor];
        view.layer.borderWidth = 2.0f;
        view.layer.borderColor = [[UIColor buttonColor] CGColor];
        view.layer.borderWidth = 2.0f;
        view.layer.borderColor = [[UIColor blackColor] CGColor];
        view.alpha = 0.5f;
        [self.scrollView addSubview:view];
    }

    for (UILabel *label in barLabelsArray) {
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        [self.scrollView addSubview:label];
        }
    }

    verticalOffset = verticalOffset + 20.0f;

    //Add imageview
    UIImageView *barImageView = [[UIImageView alloc] init];
    barImageView.frame = CGRectMake(self.scrollView.frame.size.width - 130, verticalOffset, 120, 120);
    barImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.barFromSourceVC.businessImageURL]]];
    barImageView.layer.masksToBounds = YES;
    barImageView.layer.cornerRadius = 5.0f;
    [self.scrollView addSubview:barImageView];

    //Bar name label
    UILabel *barNameLabel = [[UILabel alloc] init];
    barNameLabel.frame = CGRectMake(10 , verticalOffset, (self.scrollView.frame.size.width - barImageView.frame.size.width - 30) , 30);
    barNameLabel.text = self.barFromSourceVC.name;
    [barNameLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:17]];
    barNameLabel.textAlignment = NSTextAlignmentLeft;
    barNameLabel.numberOfLines = 0;
    [barNameLabel sizeToFit];
    barNameLabel.textColor = [UIColor nameColor];
    [self.scrollView addSubview:barNameLabel];

    verticalOffset = verticalOffset + barNameLabel.frame.size.height + 5;

    //Bar address label
    UILabel *barAddressLabel = [[UILabel alloc] init];
    barAddressLabel.frame = CGRectMake(10, verticalOffset, (self.scrollView.frame.size.width - barImageView.frame.size.width - 30), 30);
    barAddressLabel.text = self.barFromSourceVC.address;
    [barAddressLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:12]];
    barAddressLabel.textAlignment = NSTextAlignmentLeft;
    barAddressLabel.numberOfLines = 0;
    [barAddressLabel sizeToFit];
    barAddressLabel.textColor = [UIColor whiteColor];
    [self.scrollView addSubview:barAddressLabel];

    verticalOffset = verticalOffset + barAddressLabel.frame.size.height + 5;

    UILabel *distanceFromUserLabel = [[UILabel alloc] init];
    distanceFromUserLabel.frame = CGRectMake(10, verticalOffset, (self.scrollView.frame.size.width - barImageView.frame.size.width - 30), 30);
    distanceFromUserLabel.text = [NSString stringWithFormat:@"%.02f miles", self.barFromSourceVC.distanceFromUser * 0.000621371];
    [distanceFromUserLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:12]];
    distanceFromUserLabel.textAlignment = NSTextAlignmentLeft;
    distanceFromUserLabel.numberOfLines = 0;
    [distanceFromUserLabel sizeToFit];
    distanceFromUserLabel.textColor = [UIColor whiteColor];
    [self.scrollView addSubview:distanceFromUserLabel];

    verticalOffset = verticalOffset + distanceFromUserLabel.frame.size.height + 10;

    _telephoneOutlet = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _telephoneOutlet.frame = CGRectMake(10, verticalOffset, (self.scrollView.frame.size.width - barImageView.frame.size.width - 30), 30);
    [_telephoneOutlet setTitleColor:[UIColor buttonColor] forState:UIControlStateNormal];
    _telephoneOutlet.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;

    if (self.barFromSourceVC.telephone) {
        [_telephoneOutlet setTitle:[NSString stringWithFormat:@"(%@) %@-%@", [self.barFromSourceVC.telephone substringWithRange:NSMakeRange(0, 3)], [self.barFromSourceVC.telephone substringWithRange:NSMakeRange(3, 3)], [self.barFromSourceVC.telephone substringWithRange:NSMakeRange(6, 4)]] forState:UIControlStateNormal];

        [_telephoneOutlet addTarget:self
                                 action:@selector(onTelephoneButtonPressed:)
                       forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        [_telephoneOutlet setTitle:@"Tel # unavailable" forState:UIControlStateNormal];
        _telephoneOutlet.enabled = NO;
    }
    [self.scrollView addSubview:_telephoneOutlet];

    verticalOffset = verticalOffset + _telephoneOutlet.frame.size.height + 10;

    UIButton *goToWebsiteButtonOutlet = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [goToWebsiteButtonOutlet addTarget:self
                                     action:@selector(seeOnYelp:)
                           forControlEvents:UIControlEventTouchUpInside];
    [goToWebsiteButtonOutlet setTitle:[NSString stringWithFormat:@"See %@ on Yelp", self.barFromSourceVC.name] forState:UIControlStateNormal];
    goToWebsiteButtonOutlet.frame = CGRectMake(10, verticalOffset, (self.scrollView.frame.size.width - 20), 30);
    [goToWebsiteButtonOutlet setTitleColor:[UIColor buttonColor] forState:UIControlStateNormal];
    [goToWebsiteButtonOutlet setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    goToWebsiteButtonOutlet.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.scrollView addSubview:goToWebsiteButtonOutlet];

    verticalOffset = verticalOffset + goToWebsiteButtonOutlet.frame.size.height + 10;

    UILabel *categoriesLabel = [[UILabel alloc] init];
    categoriesLabel.frame = CGRectMake(10, verticalOffset, (self.scrollView.frame.size.width - 20), 30);
    categoriesLabel.text = [NSString stringWithFormat:@"Category:  %@\nOffers:  %@", self.barFromSourceVC.categories, self.barFromSourceVC.offers];
    [categoriesLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:12]];
    categoriesLabel.textAlignment = NSTextAlignmentLeft;
    categoriesLabel.numberOfLines = 0;
    [categoriesLabel sizeToFit];
    categoriesLabel.textColor = [UIColor whiteColor];
    [self.scrollView addSubview:categoriesLabel];

    verticalOffset = verticalOffset + categoriesLabel.frame.size.height + 10;

    UILabel *yelpReviewersSayLabel = [[UILabel alloc] init];
    yelpReviewersSayLabel.frame = CGRectMake(10, verticalOffset, (self.scrollView.frame.size.width - 20), 30);
    yelpReviewersSayLabel.text = @"Yelp reviewers are saying...";
    [yelpReviewersSayLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12]];
    yelpReviewersSayLabel.textAlignment = NSTextAlignmentLeft;
    yelpReviewersSayLabel.numberOfLines = 0;
    [yelpReviewersSayLabel sizeToFit];
    yelpReviewersSayLabel.textColor = [UIColor whiteColor];
    [self.scrollView addSubview:yelpReviewersSayLabel];

    verticalOffset = verticalOffset + yelpReviewersSayLabel.frame.size.height;

    //Add Yelp user comments textview.
    UITextView *aboutBarTextView = [[UITextView alloc] init];
    aboutBarTextView.frame = CGRectMake(10, verticalOffset, (self.scrollView.frame.size.width - 20), 70);
    aboutBarTextView.text = self.barFromSourceVC.aboutBusiness;
    aboutBarTextView.editable = NO;
    aboutBarTextView.textAlignment = NSTextAlignmentLeft;
    aboutBarTextView.textColor = [UIColor whiteColor];
    aboutBarTextView.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:aboutBarTextView];

    verticalOffset = verticalOffset + aboutBarTextView.frame.size.height + 10;

    self.scrollView.contentMode = UIViewContentModeScaleAspectFit;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, verticalOffset);

    self.activityIndicator.hidden = YES;
    [self.activityIndicator stopAnimating];
}

- (void)onTelephoneButtonPressed:(id)sender
{
    _telephoneOutlet.titleLabel.textColor = [UIColor whiteColor];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@", self.barFromSourceVC.telephone]]];
}

-(void)seeOnYelp:(id)sender
{
    [self performSegueWithIdentifier:@"websegue" sender:self];
}


- (IBAction)onRefreshButtonPushed:(id)sender
{
    [self removeViews];
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
            }

        else {
            self.numberOfUsersInBarString = [NSString stringWithFormat:@"No PubChat users in %@", self.barFromSourceVC.name];
            }
        }
        else {
        self.numberOfUsersInBarString = [NSString stringWithFormat:@"No PubChat users in %@", self.barFromSourceVC.name];
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
              NSLog(@"You are in: %@", self.bar.barName);
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

    // Make sure there is a bar for which to show ratings
    if (self.bar) {

    // Perform query for ratings on the current bar.
    PFQuery *query = [PFQuery queryWithClassName:@"Rating"];
    [query includeKey:@"bar"];
    [query whereKey:@"bar" equalTo:self.bar];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects) {
            if (objects.count > 0) {

                self.ratingsCount = @(objects.count);

                // Set ratings counters to 0.
                NSInteger broCount = 0;
                NSInteger artsyCount = 0;
                NSInteger chillCount = 0;
                NSInteger hipsterCount = 0;
                NSInteger classyCount = 0;
                NSInteger diveCount = 0;
                NSInteger clubbyCount = 0;

                // Create a temporary array of userRatings strings.
                NSMutableArray *userRatings = [NSMutableArray new];
                for (Rating *rating in objects) {
                    NSString *userRating = rating.userRating;
                    [userRatings addObject:userRating];
                }

                // Iterate through all the userRatings strings and increment counters.
                for (NSString *ratingString in userRatings)
                {
                    if ([ratingString isEqual: @"Bro"]) {
                        broCount += 1;
                    }
                    else if ([ratingString  isEqual: @"Artsy"])
                    {
                        artsyCount += 1;
                    }
                    else if ([ratingString  isEqual: @"Chill"])
                    {
                        chillCount += 1;
                    }
                    else if ([ratingString  isEqual: @"Hipster"])
                    {
                        hipsterCount += 1;
                    }
                    else if ([ratingString  isEqual: @"Classy"])
                    {
                        classyCount += 1;
                    }
                    else if ([ratingString  isEqual: @"Dive"])
                    {
                        diveCount += 1;
                    }
                    else if ([ratingString  isEqual: @"Clubby"])
                    {
                        clubbyCount += 1;
                    }
                }

                // Convert NSInteger counters to NSNumber counters.
                NSNumber *broNumber = @(broCount);
                NSNumber *artsyNumber = @(artsyCount);
                NSNumber *chillNumber = @(chillCount);
                NSNumber *hipsterNumber = @(hipsterCount);
                NSNumber *classyNumber = @(classyCount);
                NSNumber *diveNumber = @(diveCount);
                NSNumber *clubbyNumber = @(clubbyCount);

                // Create ratings dictionaries.
                self.broDictionary = @{@"userRating" : @"Bro", @"Count" : broNumber};
                self.artsyDictionary = @{@"userRating" : @"Artsy", @"Count" : artsyNumber};
                self.chillDictionary = @{@"userRating" : @"Chill", @"Count" : chillNumber};
                self.hipsterDictionary = @{@"userRating" : @"Hipster", @"Count" : hipsterNumber};
                self.classyDictionary = @{@"userRating" : @"Classy", @"Count" : classyNumber};
                self.diveDictionary = @{@"userRating" : @"Dive", @"Count" : diveNumber};
                self.clubbyDictionary = @{@"userRating" : @"Clubby", @"Count" : clubbyNumber};

                // Create a temporary array and add the dictionaries.
                NSMutableArray *tempArray = [NSMutableArray new];
                [tempArray addObject:self.broDictionary];
                [tempArray addObject:self.artsyDictionary];
                [tempArray addObject:self.chillDictionary];
                [tempArray addObject:self.hipsterDictionary];
                [tempArray addObject:self.classyDictionary];
                [tempArray addObject:self.diveDictionary];
                [tempArray addObject:self.clubbyDictionary];

                // Sort the temporary array by ratings count and assign to ratingsArray. Dictionaries with the higher ratings count will be at the front of the array.
                NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"Count" ascending:NO];
                self.ratingsArray = [tempArray sortedArrayUsingDescriptors:@[descriptor]];

                // Create the pubChat info label.
                [self setViewContent];
                }
            }

        }];
    }

    else {
        [self setViewContent];
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
