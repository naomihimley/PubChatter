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
@property (weak, nonatomic) IBOutlet UILabel *inABarLabel;
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
    [self checkIfUserisInBar];
    [self style];
}

- (void)userEnteredBar: (NSNotification *)notification
{
    NSLog(@"rating notification %@", [[notification userInfo] objectForKey:@"barName"]);
    NSString *barName = [[notification userInfo] objectForKey:@"barName"];
    if ([barName isEqualToString:@"PubChat"])
    {
        self.inABarLabel.text = @"Not in a Bar";
        [self.rateBarButtonOutlet setTitle:@"Rate" forState:UIControlStateNormal];
        self.sliderOutlet.enabled = NO;
        self.rateBarButtonOutlet.enabled = NO;
    }
    else
    {
        self.inABarLabel.text = barName;
        [self.rateBarButtonOutlet setTitle:[NSString stringWithFormat:@"Rate"] forState:UIControlStateNormal];
//        self.rateBarButtonOutlet.enabled = YES;
//        self.sliderOutlet.enabled = YES;
//        [self checkIfUserHasRatedBar];
    }
}

-(void)checkIfUserisInBar
{
    PFQuery *queryForBar = [PFQuery queryWithClassName:@"Bar"];
    [queryForBar whereKey:@"usersInBar" equalTo:[PFUser currentUser]];
    [queryForBar findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects firstObject]) {
            self.bar = [objects firstObject];
//            self.inABarLabel.text = [NSString stringWithFormat:@"%@", [self.bar valueForKey:@"barName"]];
            [self.rateBarButtonOutlet setTitle:[NSString stringWithFormat:@"Rate"] forState:UIControlStateNormal];
            self.rateBarButtonOutlet.enabled = YES;
            self.sliderOutlet.enabled = YES;
            [self checkIfUserHasRatedBar];
        }
        else
        {
            self.inABarLabel.text = @"Not in a Bar";
            [self.rateBarButtonOutlet setTitle:@"Rate" forState:UIControlStateNormal];
            self.sliderOutlet.enabled = NO;
            self.rateBarButtonOutlet.enabled = NO;
        }
        self.rateBarButtonOutlet.enabled = NO;
        self.sliderOutlet.enabled = NO;
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
    self.rateBarButtonOutlet.layer.borderWidth = 1.0f;
    self.rateBarButtonOutlet.layer.borderColor= [[UIColor buttonColor]CGColor];
    self.rateBarButtonOutlet.backgroundColor = [[UIColor backgroundColor]colorWithAlphaComponent:0.8];
}

@end
