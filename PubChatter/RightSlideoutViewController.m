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

- (IBAction)onRateButtonPressed:(id)sender
{
    NSNumber *rating = @(self.sliderOutlet.value);

    Rating *barRating = [Rating objectWithClassName:@"Rating"];
    [barRating setObject:[PFUser currentUser] forKey:@"user"];
    [barRating setObject:rating forKey:@"rating"];
    [barRating setObject:self.bar forKey:@"bar"];

    [barRating saveInBackground];

    NSLog(@"%ld", (long)rating);
    NSLog(@"%@", self.bar);

}


@end
