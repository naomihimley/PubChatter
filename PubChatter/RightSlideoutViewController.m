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

@interface RightSlideoutViewController ()

@property (weak, nonatomic) IBOutlet UISlider *sliderOutlet;
@property (weak, nonatomic) IBOutlet UIButton *rateBarButtonOutlet;
@property Bar *bar;
@property Rating *rating;
@property UIView *rateIndicator;
@property (weak, nonatomic) IBOutlet UILabel *inABarLabel;
@property UIDynamicAnimator *dynamicAnimator;
@property UIPushBehavior *pushBehavior;
@property UIDynamicItemBehavior *dynamicItemBehaviorIndicator;


-(void)userEnteredBar:(NSNotification *)notification;

@end

@implementation RightSlideoutViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.sliderOutlet.minimumValue = 0;
    self.sliderOutlet.maximumValue = 5;
    self.sliderOutlet.value = 0;
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
    NSLog(@"view did appear");
    self.sliderOutlet.enabled = NO;
    self.rateBarButtonOutlet.enabled = NO;
    [self checkIfUserisInBar];
    [self createRateIndicator];
    [self style];
}

-(void)createRateIndicator
{
    // Create the sliding rate indicator and add to view (eventually replace view with better-looking image)
    CGFloat indicatorWidth = 50;
    self.rateIndicator = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - indicatorWidth, self.view.frame.size.height/2, indicatorWidth, 30)];
    self.rateIndicator.backgroundColor = [UIColor buttonColor];
    [self.view addSubview:self.rateIndicator];

    // Set up pan gesture recognizer
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.view addGestureRecognizer:pan];
}

- (void)handlePan:(UIPanGestureRecognizer *)pan
{
    // Lock rate indicator x location and make y location the locationinview of pan gesture recognizer. Creates the up/down sliding effect.
    self.rateIndicator.center = CGPointMake(self.rateIndicator.center.x, [pan locationInView:self.view].y);
    [self.dynamicAnimator updateItemUsingCurrentState:self.rateIndicator];

    // Dynamically update the background color based on pan gesture locationinview.

    // Max RGB value
    CGFloat max = 255.0;

    // Scale pan locationinview to the (0-255) range of RGB values.
    CGFloat redScaler = ([pan locationInView:self.view].y/self.view.frame.size.height)*255;
    CGFloat blueScaler = max -  ([pan locationInView:self.view].y/self.view.frame.size.height)*255;

    // Apply scaler values to background color. When pan is at the bottom of the view, blueScaler is low and redScaler is high (i.e. more red), and vice versa.
    CGFloat red = redScaler/255.0;
    CGFloat green = 0.0/255.0;
    CGFloat blue = blueScaler/255.0;
    UIColor *backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1];

    // Set background color.
    self.view.backgroundColor = backgroundColor;
}

#pragma mark - Notifications
//iBeacon Notification, sends the BarName on region entry and 'PubChat' on region exit
- (void)userEnteredBar: (NSNotification *)notification
{
    NSString *barName = [[notification userInfo] objectForKey:@"barName"];
    if ([barName isEqualToString:@"PubChat"])
    {
        self.inABarLabel.text = @"Not in a Bar";
    }
    else
    {
        self.inABarLabel.text = barName;
    }
}

#pragma mark - Parse Methods
-(void)checkIfUserisInBar
{
    PFQuery *queryForBar = [PFQuery queryWithClassName:@"Bar"];
    [queryForBar whereKey:@"usersInBar" equalTo:[PFUser currentUser]];
    [queryForBar findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects firstObject]) {
            self.bar = [objects firstObject];
            NSLog(@"they are in this bar: %@", [self.bar objectForKey:@"barName"]);
            [self.rateBarButtonOutlet setTitle:[NSString stringWithFormat:@"Rate"] forState:UIControlStateNormal];
            self.rateBarButtonOutlet.enabled = YES;
            self.sliderOutlet.enabled = YES;
            self.inABarLabel.text = [self.bar objectForKey:@"barName"];
            [self checkIfUserHasRatedBar];
        }
        else
        {
            self.inABarLabel.text = @"Not in a Bar";
            [self.rateBarButtonOutlet setTitle:@"Rate" forState:UIControlStateNormal];
            self.sliderOutlet.enabled = NO;
            self.rateBarButtonOutlet.enabled = NO;
        }
    }];
}

-(void)checkIfUserHasRatedBar
{
    PFQuery *queryForRating = [PFQuery queryWithClassName:@"Rating"];
    [queryForRating whereKey:@"user" equalTo:[PFUser currentUser]];
    [queryForRating findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects firstObject])
        {
            self.rating = [objects firstObject];
        }
    }];
}

#pragma mark - Button Pressed Methods
- (IBAction)onRateButtonPressed:(id)sender
{
    if (self.rating) {
        NSInteger rtg= @(self.sliderOutlet.value).intValue;
        NSNumber *rating = @(rtg);
        [self.rating setObject:rating forKey:@"rating"];
        [self.rating saveInBackground];
    }

    else
    {
        NSInteger rtg= @(self.sliderOutlet.value).intValue;
        NSNumber *rating = @(rtg);
        Rating *barRating = [Rating objectWithClassName:@"Rating"];
        [barRating setObject:rating forKey:@"rating"];
        [barRating setObject:[PFUser currentUser] forKey:@"user"];
        [barRating setObject:self.bar forKey:@"bar"];
        [barRating saveInBackground];
    }
}

#pragma mark - Style Method
- (void)style
{
    self.inABarLabel.textColor = [UIColor nameColor];
    [self.sliderOutlet setMinimumTrackTintColor:[UIColor nameColor]];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"river"]];
    [self.rateBarButtonOutlet setTitleColor:[UIColor buttonColor] forState:UIControlStateNormal];
    [self.rateBarButtonOutlet setTitleColor:[UIColor buttonColor] forState:UIControlStateHighlighted];
    [self.rateBarButtonOutlet setTitleColor:[UIColor buttonColor] forState:UIControlStateSelected];
    self.rateBarButtonOutlet.layer.cornerRadius = 5.0f;
    self.rateBarButtonOutlet.layer.masksToBounds = YES;
    self.rateBarButtonOutlet.layer.borderWidth = 2.0f;
    self.rateBarButtonOutlet.layer.borderColor= [[UIColor buttonColor]CGColor];
    self.rateBarButtonOutlet.backgroundColor = [[UIColor backgroundColor]colorWithAlphaComponent:0.8];
}

@end
