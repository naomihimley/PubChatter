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

@interface RightSlideoutViewController ()

@property (weak, nonatomic) IBOutlet UISlider *sliderOutlet;
@property (weak, nonatomic) IBOutlet UIButton *rateBarButtonOutlet;
@property Bar *bar;
@property Rating *rating;

@end

@implementation RightSlideoutViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.sliderOutlet.minimumValue = 0;
    self.sliderOutlet.maximumValue = 5;
    self.sliderOutlet.value = 0;
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.rateBarButtonOutlet.enabled = NO;
    self.sliderOutlet.enabled = NO;
    [self checkIfUserisInBar];
}

-(void)checkIfUserisInBar
{
    PFQuery *queryForBar = [PFQuery queryWithClassName:@"Bar"];
    [queryForBar whereKey:@"usersInBar" equalTo:[PFUser currentUser]];
    [queryForBar findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects firstObject]) {
            NSLog(@"A");
            self.bar = [objects firstObject];
            [self.rateBarButtonOutlet setTitle:[NSString stringWithFormat:@"Rate %@", [self.bar valueForKey:@"barName"]] forState:UIControlStateNormal];
            self.rateBarButtonOutlet.enabled = YES;
            self.sliderOutlet.enabled = YES;
            [self checkIfUserHasRatedBar];
        }
        else
        {
            NSLog(@"B");
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

        NSLog(@"%@", rating);
        NSLog(@"%@", [self.bar objectForKey:@"name"]);
    }
}


@end
