//
//  RightSlideoutViewController.m
//  PubChatter
//
//  Created by David Warner on 6/23/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import "RightSlideoutViewController.h"
#import <Parse/Parse.h>
#import "Rating.h"
#import "Bar.h"
#import "UIColor+DesignColors.h"
#import <CoreGraphics/CoreGraphics.h>

@interface RightSlideoutViewController ()

@property Bar *bar;
@property Rating *rating;
@property UIView *rateIndicator;
@property UIButton *button1;
@property UIButton *button2;
@property UIButton *button3;
@property UIButton *button4;
@property UIButton *button5;
@property UIButton *button6;
@property UIButton *button7;
@property UIView *ratingView;
@property NSMutableArray *buttonsArray;
@property CGFloat ratingViewHeight;
@property CGFloat buttonWidth;
@property CGFloat buttonHeight;
@property UIPushBehavior *pushBehavior;
@property UIDynamicItemBehavior *dynamicItemBehaviorIndicator;


-(void)userEnteredBar:(NSNotification *)notification;

@end

@implementation RightSlideoutViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(userEnteredBar:)
                                                name:@"userEnteredBar"
                                              object:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"chatBox"
                                                       object:nil
                                                     userInfo:@{@"toBeaconRegionManager": @"whatBarAmIIn"}];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self removeViewFromSuperview];

    [self style];
}

-(void)removeViewFromSuperview
{
    [self.button1 removeFromSuperview];
    [self.button2 removeFromSuperview];
    [self.button3 removeFromSuperview];
    [self.button4 removeFromSuperview];
    [self.button5 removeFromSuperview];
    [self.button6 removeFromSuperview];
    [self.button7 removeFromSuperview];
    [self.ratingView removeFromSuperview];
    [self.rateIndicator removeFromSuperview];

    [self checkIfUserisInBar];
}

#pragma mark - Parse Methods
-(void)checkIfUserisInBar
{
    NSLog(@"Checking if user is in a bar");
    PFQuery *queryForBar = [PFQuery queryWithClassName:@"Bar"];
    [queryForBar whereKey:@"usersInBar" equalTo:[PFUser currentUser]];
    [queryForBar findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects firstObject]) {
            self.bar = [objects firstObject];
            UINavigationController *navCon  = (UINavigationController*) [self.navigationController.viewControllers objectAtIndex:0];
            navCon.navigationItem.title = self.bar.barName;
            [self checkIfUserHasRatedBar];
            NSLog(@"User is in: %@", self.bar.barName);
        }
        else
        {
        }
    }];
}

-(void)checkIfUserHasRatedBar
{
    NSLog(@"Checking for rating");
    PFQuery *queryForRating = [PFQuery queryWithClassName:@"Rating"];
    [queryForRating whereKey:@"user" equalTo:[PFUser currentUser]];
    [queryForRating whereKey:@"bar" equalTo:self.bar];
    [queryForRating findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects firstObject])
        {
            self.rating = [objects firstObject];
            [self createRatingLabel];
            NSLog(@"User has rated %@: %@", self.bar.barName, self.rating.userRating);
        }
        else{
            [self createRatingLabel];
            NSLog(@"User has not rated %@", self.bar.barName);
        }
    }];
}

-(void)createRatingLabel
{
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat navBarHeight = self.navigationController.navigationBar.frame.size.height;
    self.ratingViewHeight = 60.0f;

    self.ratingView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x + 55, statusBarHeight + navBarHeight, self.view.frame.size.width -50, self.ratingViewHeight)];
    self.ratingView.backgroundColor = [UIColor clearColor];
    self.ratingView.layer.borderWidth = 2.0f;
    self.ratingView.layer.borderColor = [[UIColor buttonColor] CGColor];
    [self.view addSubview:self.ratingView];

    UILabel *ratingTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.ratingView.frame.size.width -20, self.ratingView.frame.size.height - 20)];

    if (self.rating) {
        ratingTextLabel.text = [NSString stringWithFormat:@"Your rating: %@", self.rating.userRating];
    }
    else {
        ratingTextLabel.text = [NSString stringWithFormat:@"Rate %@", self.bar.barName];;
    }

    ratingTextLabel.textColor = [UIColor buttonColor];
    ratingTextLabel.textAlignment = NSTextAlignmentCenter;
    [self.ratingView addSubview:ratingTextLabel];

    [self createRateIndicatorandLabels];
}


-(void)createRateIndicatorandLabels
{
    // Create the sliding rate indicator and add to view (eventually replace view with better-looking image)
    CGFloat indicatorWidth = 100;

    self.rateIndicator = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.size.height/2, indicatorWidth, 30)];
    self.rateIndicator.backgroundColor = [UIColor redColor];
    self.rateIndicator.layer.cornerRadius = 50;
    [self.view addSubview:self.rateIndicator];

    // Set up pan gesture recognizer
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.view addGestureRecognizer:pan];

    //Create buttons
    self.buttonsArray = [NSMutableArray new];

    self.button1 = [UIButton new];
    self.button2 = [UIButton new];
    self.button3 = [UIButton new];
    self.button4 = [UIButton new];
    self.button5 = [UIButton new];
    self.button6 = [UIButton new];
    self.button7 = [UIButton new];

    [self.button1 setTitle:@"   Bro" forState:UIControlStateNormal];
    [self.button2 setTitle:@"   Artsy" forState:UIControlStateNormal];
    [self.button3 setTitle:@"   Chill" forState:UIControlStateNormal];
    [self.button4 setTitle:@"   Hipster" forState:UIControlStateNormal];
    [self.button5 setTitle:@"   Classy" forState:UIControlStateNormal];
    [self.button6 setTitle:@"   Dive" forState:UIControlStateNormal];
    [self.button7 setTitle:@"   Clubby" forState:UIControlStateNormal];

    [self.buttonsArray addObject:self.button1];
    [self.buttonsArray addObject:self.button2];
    [self.buttonsArray addObject:self.button3];
    [self.buttonsArray addObject:self.button4];
    [self.buttonsArray addObject:self.button5];
    [self.buttonsArray addObject:self.button6];
    [self.buttonsArray addObject:self.button7];

    // Get status and nav bar height so vertical offset and height of labels can be set precisely.
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat navBarHeight = self.navigationController.navigationBar.frame.size.height;

    self.buttonWidth = 150.0f;
    self.buttonHeight = (self.view.frame.size.height - statusBarHeight - navBarHeight - self.ratingViewHeight)/self.buttonsArray.count;
    CGFloat verticalOffset = statusBarHeight + navBarHeight + self.ratingViewHeight;

    for (UIButton *button in self.buttonsArray) {
        button.frame = CGRectMake(self.view.frame.size.width - (self.buttonWidth/2), verticalOffset, self.buttonWidth, self.buttonHeight);
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [button setTitleColor:[UIColor buttonColor] forState:UIControlStateNormal];
        button.backgroundColor = [UIColor clearColor];
        button.layer.borderWidth = 2.0f;
        button.layer.borderColor = [[UIColor buttonColor] CGColor];
        button.layer.cornerRadius = 5.0f;
        button.enabled = NO;
        [button addTarget:self
                         action:@selector(buttonSelected:)
               forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        verticalOffset = verticalOffset + self.buttonHeight;
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)pan
{
    // Lock rate indicator x location and make y location the locationinview of pan gesture recognizer. Creates the up/down sliding effect.
    self.rateIndicator.center = CGPointMake(self.rateIndicator.center.x, [pan locationInView:self.view].y);

    // Slide out the label views when the indicator view is in their vertical range.
    if ([pan locationInView:self.view].y > self.button1.frame.origin.y && [pan locationInView:self.view].y < self.button1.frame.origin.y + self.button1.frame.size.height) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelay:0.0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];

        self.button1.frame = CGRectMake(self.view.frame.size.width - self.buttonWidth, self.button1.frame.origin.y, self.buttonWidth, self.buttonHeight);
        self.button1.backgroundColor = [UIColor buttonColor];
        [self.button1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.button1.enabled = YES;
        [UIView commitAnimations];
    }
    else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelay:0.0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];

        self.button1.frame = CGRectMake(self.view.frame.size.width - (self.buttonWidth/2), self.button1.frame.origin.y, self.buttonWidth, self.buttonHeight);
        self.button1.backgroundColor = [UIColor clearColor];
        [self.button1 setTitleColor:[UIColor buttonColor] forState:UIControlStateNormal];
        self.button1.enabled = NO;
        [UIView commitAnimations];
    }

    if ([pan locationInView:self.view].y > self.button2.frame.origin.y && [pan locationInView:self.view].y < self.button2.frame.origin.y + self.button2.frame.size.height) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelay:0.0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];

        self.button2.frame = CGRectMake(self.view.frame.size.width - self.buttonWidth, self.button2.frame.origin.y, self.buttonWidth, self.buttonHeight);
        self.button2.backgroundColor = [UIColor buttonColor];
        [self.button2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.button2.enabled = YES;
        [UIView commitAnimations];
    }
    else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelay:0.0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];

        self.button2.frame = CGRectMake(self.view.frame.size.width - (self.buttonWidth/2), self.button2.frame.origin.y, self.buttonWidth, self.buttonHeight);
        self.button2.backgroundColor = [UIColor clearColor];
        [self.button2 setTitleColor:[UIColor buttonColor] forState:UIControlStateNormal];
        self.button2.enabled = NO;
        [UIView commitAnimations];
    }

    if ([pan locationInView:self.view].y > self.button3.frame.origin.y && [pan locationInView:self.view].y < self.button3.frame.origin.y + self.button3.frame.size.height) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelay:0.0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];

        self.button3.frame = CGRectMake(self.view.frame.size.width - self.buttonWidth, self.button3.frame.origin.y, self.buttonWidth, self.buttonHeight);
        self.button3.backgroundColor = [UIColor buttonColor];
        [self.button3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.button3.enabled = YES;
        [UIView commitAnimations];
    }
    else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelay:0.0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];

        self.button3.frame = CGRectMake(self.view.frame.size.width - (self.buttonWidth/2), self.button3.frame.origin.y, self.buttonWidth, self.buttonHeight);
        self.button3.backgroundColor = [UIColor clearColor];
        [self.button3 setTitleColor:[UIColor buttonColor] forState:UIControlStateNormal];
        self.button3.enabled = NO;
        [UIView commitAnimations];
    }

    if ([pan locationInView:self.view].y > self.button4.frame.origin.y && [pan locationInView:self.view].y < self.button4.frame.origin.y + self.button4.frame.size.height) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelay:0.0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];

        self.button4.frame = CGRectMake(self.view.frame.size.width - self.buttonWidth, self.button4.frame.origin.y, self.buttonWidth, self.buttonHeight);
        self.button4.backgroundColor = [UIColor buttonColor];
        [self.button4 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.button4.enabled = YES;
        [UIView commitAnimations];
    }
    else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelay:0.0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];

        self.button4.frame = CGRectMake(self.view.frame.size.width - (self.buttonWidth/2), self.button4.frame.origin.y, self.buttonWidth, self.buttonHeight);
        self.button4.backgroundColor = [UIColor clearColor];
        [self.button4 setTitleColor:[UIColor buttonColor] forState:UIControlStateNormal];
        self.button4.enabled = NO;
        [UIView commitAnimations];
    }

    if ([pan locationInView:self.view].y > self.button5.frame.origin.y && [pan locationInView:self.view].y < self.button5.frame.origin.y + self.button5.frame.size.height) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelay:0.0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];

        self.button5.frame = CGRectMake(self.view.frame.size.width - self.buttonWidth, self.button5.frame.origin.y, self.buttonWidth, self.buttonHeight);
        self.button5.backgroundColor = [UIColor buttonColor];
        [self.button5 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.button5.enabled = YES;
        [UIView commitAnimations];
    }
    else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelay:0.0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];

        self.button5.frame = CGRectMake(self.view.frame.size.width - (self.buttonWidth/2), self.button5.frame.origin.y, self.buttonWidth, self.buttonHeight);
        self.button5.backgroundColor = [UIColor clearColor];
        [self.button5 setTitleColor:[UIColor buttonColor] forState:UIControlStateNormal];
        self.button5.enabled = NO;
        [UIView commitAnimations];
    }

    if ([pan locationInView:self.view].y > self.button6.frame.origin.y && [pan locationInView:self.view].y < self.button6.frame.origin.y + self.button6.frame.size.height) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelay:0.0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];

        self.button6.frame = CGRectMake(self.view.frame.size.width - self.buttonWidth, self.button6.frame.origin.y, self.buttonWidth, self.buttonHeight);
        self.button6.backgroundColor = [UIColor buttonColor];
        [self.button6 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.button6.enabled = YES;
        [UIView commitAnimations];
    }
    else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelay:0.0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];

        self.button6.frame = CGRectMake(self.view.frame.size.width - (self.buttonWidth/2), self.button6.frame.origin.y, self.buttonWidth, self.buttonHeight);
        self.button6.backgroundColor = [UIColor clearColor];
        [self.button6 setTitleColor:[UIColor buttonColor] forState:UIControlStateNormal];
        self.button6.enabled = NO;
        [UIView commitAnimations];
    }

    if ([pan locationInView:self.view].y > self.button7.frame.origin.y && [pan locationInView:self.view].y < self.button7.frame.origin.y + self.button7.frame.size.height) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelay:0.0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];

        self.button7.frame = CGRectMake(self.view.frame.size.width - self.buttonWidth, self.button7.frame.origin.y, self.buttonWidth, self.buttonHeight);
        self.button7.backgroundColor = [UIColor buttonColor];
        [self.button7 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.button7.enabled = YES;
        [UIView commitAnimations];
    }
    else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelay:0.0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];

        self.button7.frame = CGRectMake(self.view.frame.size.width - (self.buttonWidth/2), self.button7.frame.origin.y, self.buttonWidth, self.buttonHeight);
        self.button7.backgroundColor = [UIColor clearColor];
        [self.button7 setTitleColor:[UIColor buttonColor] forState:UIControlStateNormal];
        self.button7.enabled = NO;
        [UIView commitAnimations];
    }
}

-(void)buttonSelected:(id)sender
{
    for (UIButton *button in self.buttonsArray) {
        if ([button isEnabled]) {
            NSString *userSelection = button.titleLabel.text;
            if (self.rating) {
                NSLog(@"User is changing their rating");
                NSString *selectionWithoutSpaces = [userSelection stringByReplacingOccurrencesOfString:@" " withString:@""];
                NSLog(@"%@", selectionWithoutSpaces);
                self.rating.userRating = selectionWithoutSpaces;
                [self.rating saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    [self removeViewFromSuperview];
                }];
            }
            else {
                NSLog(@"User is rating bar for the first time");
                Rating *barRating = [Rating objectWithClassName:@"Rating"];
                NSString *selectionWithoutSpaces = [userSelection stringByReplacingOccurrencesOfString:@" " withString:@""];
                [barRating setObject:selectionWithoutSpaces forKey:@"userRating"];
                [barRating setObject:[PFUser currentUser] forKey:@"user"];
                [barRating setObject:self.bar forKey:@"bar"];

                [barRating saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    [self removeViewFromSuperview];
                }];
            }
        }
    }
}

#pragma mark - Notifications
//iBeacon Notification, sends the BarName on region entry and 'PubChat' on region exit
- (void)userEnteredBar: (NSNotification *)notification
{
    NSString *barName = [[notification userInfo] objectForKey:@"barName"];
    if ([barName isEqualToString:@"PubChat"])
    {
    }
    else
    {
    }
}


#pragma mark - Style Method
- (void)style
{
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"river"]];
}

@end
