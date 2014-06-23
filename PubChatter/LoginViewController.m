//
//  LoginViewController.m
//  PubChatter
//
//  Created by David Warner on 6/23/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>

@interface LoginViewController ()

@end

@implementation LoginViewController



- (void)viewDidLoad
{
    [super viewDidLoad];

        PFLogInViewController *loginViewController = [PFLogInViewController new];
        loginViewController.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsLogInButton | PFLogInFieldsTwitter | PFLogInFieldsFacebook;
        PFSignUpViewController *signupViewController = [PFSignUpViewController new];
        signupViewController.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsLogInButton | PFLogInFieldsTwitter | PFLogInFieldsFacebook;
        loginViewController.delegate = self;
        signupViewController.delegate = self;
        loginViewController.signUpController = signupViewController;
        [self presentViewController:loginViewController animated:YES completion:nil];
}



@end
