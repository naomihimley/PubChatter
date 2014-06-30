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
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation InitialViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageView.image = [UIImage imageNamed:@"river"];
    [self.activityIndicator startAnimating];
}

-(void)viewDidAppear:(BOOL)animated
{

    if (![PFUser currentUser]) {
        [self performSegueWithIdentifier:@"loginsegue" sender:self];
    }
    else {
        [self performSegueWithIdentifier:@"onward" sender:self];
    }
}



@end
