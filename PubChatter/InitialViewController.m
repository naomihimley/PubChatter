//
//  InitialViewController.m
//  PubChatter
//
//  Created by David Warner on 6/26/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import "InitialViewController.h"
#import <Parse/Parse.h>

@interface InitialViewController ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation InitialViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self.activityIndicator startAnimating];

    if (![PFUser currentUser]) {
        [self performSegueWithIdentifier:@"loginsegue" sender:self];
    }
    else {
        [self performSegueWithIdentifier:@"onward" sender:self];
    }
}



@end
