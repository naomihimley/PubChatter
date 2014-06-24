//
//  LoginViewController.m
//  PubChatter
//
//  Created by David Warner on 6/23/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>

@interface LoginViewController () <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

@end

@implementation LoginViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // Instantiate login and signup viewcontrollers.
    PFLogInViewController *loginViewController = [PFLogInViewController new];
    loginViewController.fields =  PFLogInFieldsFacebook | PFLogInFieldsUsernameAndPassword | PFLogInFieldsSignUpButton | PFLogInFieldsLogInButton;
    loginViewController.delegate = self;

    PFSignUpViewController *signUpViewController = [PFSignUpViewController new];
    signUpViewController.delegate = self;
    loginViewController.signUpController = signUpViewController;
    [self presentViewController:loginViewController animated:YES completion:nil];

    // Specifies necessary app permissions from Facebook.
    [loginViewController setFacebookPermissions:[NSArray arrayWithObjects:@"public_profile", @"user_about_me", @"user_birthday", @"user_relationship_details", nil]];
}

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length != 0 && password.length != 0) {
        return YES; // Begin login process
    }

    [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                message:@"Be sure to complete all of the information!"
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}

// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;

    // loop through all of the submitted data
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0) { // check completion
            informationComplete = NO;
            break;
        }
    }

    // Display an alert if a field wasn't completed
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                    message:@"Be sure to complete all of the information!"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }

    return informationComplete;
}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
    // Checks if user is logged in with Facebook and updates the Parse database accordingly.
    [self updateFacebookData];
    [self dismissViewControllerAnimated:YES completion:NULL];
    [self performSegueWithIdentifier:@"loginsegue" sender:self];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {

    [[[UIAlertView alloc] initWithTitle:@"Login Failed"
                                message:@"Check that your login information is correct"
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController
{
    // Instantiate login and signup viewcontrollers.
    PFLogInViewController *loginViewController = [PFLogInViewController new];
    loginViewController.fields =  PFLogInFieldsFacebook | PFLogInFieldsUsernameAndPassword | PFLogInFieldsSignUpButton | PFLogInFieldsLogInButton;
    loginViewController.delegate = self;

    PFSignUpViewController *signUpViewController = [PFSignUpViewController new];
    signUpViewController.delegate = self;
    loginViewController.signUpController = signUpViewController;
    [self presentViewController:loginViewController animated:YES completion:nil];

    // Specifies necessary app permissions from Facebook.
    [loginViewController setFacebookPermissions:[NSArray arrayWithObjects:@"public_profile", @"user_about_me", @"user_birthday", @"user_relationship_details", nil]];
}

// Retrieves Facebook data and populates the Parse database accordingly.
- (void)updateFacebookData
{
    if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        // Create request for user's Facebook data
        FBRequest *request = [FBRequest requestForMe];
        // Send request to Facebook
        [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                NSDictionary *userData = (NSDictionary *)result;
                NSLog(@"%@", userData);

                // Set name field in Parse from Facebook.
                [[PFUser currentUser]setObject:userData[@"name"] forKey:@"username"];

                // Set gender field in Parse from Facebook.
                if ([userData[@"gender"] isEqualToString:@"male"]) {
                    [[PFUser currentUser]setObject:@1 forKey:@"gender"];
                }
                else if ([userData[@"gender"] isEqualToString:@"female"]) {
                    [[PFUser currentUser]setObject:@0 forKey:@"gender"];
                }
                else {
                    [[PFUser currentUser]setObject:@2 forKey:@"gender"];
                }

                // Save profile picture to Parse backend from Facebook.
                NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", userData[@"id"]]];
                PFFile *imageFile = [PFFile fileWithData:[NSData dataWithContentsOfURL:pictureURL]];
                [[PFUser currentUser] setObject:imageFile forKey:@"picture"];

                // Set bio from Facebook and set it in the Parse backend.
                [[PFUser currentUser]setObject:userData[@"bio"] forKey:@"bio"];

                // Set age label from Facebook and set age in Parse backend.
                NSString *birthday = userData[@"birthday"];
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                [formatter setLocale:[NSLocale systemLocale]];
                [formatter setDateFormat:@"MM/dd/yyyy"];

                NSDate *formatted = [formatter dateFromString:birthday];
                NSDate *currentDate = [NSDate date];

                NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                NSDateComponents *components = [gregorianCalendar components:NSYearCalendarUnit
                                                                    fromDate:formatted
                                                                      toDate:currentDate
                                                                     options:0];

                NSNumber *age = @(components.year);
                [[PFUser currentUser]setObject:age forKey:@"age"];

                // Get "interested in" from Facebook and set in Parse backend
                for (NSString *object in userData[@"interested_in"]) {
                    if ([object isEqual:@"female"]) {
                        [[PFUser currentUser]setObject:@1 forKey:@"sexualOrientation"];
                    }
                    else if ([object isEqual:@"male"]) {
                        [[PFUser currentUser]setObject:@0 forKey:@"sexualOrientation"];
                    }
                    else {
                        [[PFUser currentUser]setObject:@2 forKey:@"sexualOrientation"];
                    }
                }
            }
            [[PFUser currentUser] saveInBackground];
        }];
    }
}





@end
