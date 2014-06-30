//
//  LoginViewController.m
//  PubChatter
//
//  Created by David Warner on 6/23/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import "LoginViewController.h"
#import "SearchViewController.h"
#import "UIColor+DesignColors.h"
#import <Parse/Parse.h>

@interface LoginViewController () <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end

@implementation LoginViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    self.facebookPermissions = @[@"public_profile", @"user_about_me", @"user_birthday", @"user_relationship_details"];
    self.fields = PFLogInFieldsFacebook | PFLogInFieldsSignUpButton | PFLogInFieldsDefault;
    self.logInView.dismissButton.alpha = 0.0;
    self.delegate = self;
//    self.backgroundImageView.image = [UIImage imageNamed:@"riverpic"];
    [self.logInView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"river"]]];

    self.logInView.usernameField.backgroundColor = [UIColor backgroundColor];
    self.logInView.usernameField.layer.opacity = 0.9f;
    self.logInView.passwordField.backgroundColor = [UIColor backgroundColor];
    self.logInView.passwordField.layer.opacity = 0.9f;
    self.logInView.usernameField.textColor = [UIColor whiteColor];
    self.logInView.passwordField.textColor = [UIColor whiteColor];
    UIColor *color = [UIColor whiteColor];
    self.logInView.usernameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"User Name" attributes:@{NSForegroundColorAttributeName: color}];
    self.logInView.passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: color}];
    self.logInView.usernameField.layer.cornerRadius = 5.0f;
    self.logInView.passwordField.layer.cornerRadius = 5.0f;

    [self.logInView.logInButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];


    self.logInView.logo = nil;
    self.delegate = self;

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    PFSignUpViewController *signUpViewController = [PFSignUpViewController new];
    signUpViewController.delegate = self;
    self.signUpController = signUpViewController;
    [self.signUpController.signUpView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"river"]]];
    
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
    [self performSegueWithIdentifier:@"next" sender:self];
//    [self dismissViewControllerAnimated:YES completion:nil];
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
    [self.logInView setBackgroundColor:[UIColor blackColor]];
    self.fields =  PFLogInFieldsFacebook | PFLogInFieldsUsernameAndPassword | PFLogInFieldsSignUpButton | PFLogInFieldsLogInButton;
    PFSignUpViewController *signUpViewController = [PFSignUpViewController new];
    signUpViewController.delegate = self;
    self.signUpController = signUpViewController;
    self.delegate = self;
    [self setFacebookPermissions:[NSArray arrayWithObjects:@"public_profile", @"user_about_me", @"user_birthday", @"user_relationship_details", nil]];
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
                // Set name field in Parse from Facebook.
                if (userData [@"first_name"]) {
                    [[PFUser currentUser]setObject:userData[@"first_name"] forKey:@"name"];
                }

                // Set gender field in Parse from Facebook.
                if (userData[@"gender"]) {
                    if ([userData[@"gender"] isEqualToString:@"male"]) {
                        [[PFUser currentUser]setObject:@1 forKey:@"gender"];
                    }
                    else if ([userData[@"gender"] isEqualToString:@"female"]) {
                        [[PFUser currentUser]setObject:@0 forKey:@"gender"];
                    }
                    else {
                        [[PFUser currentUser]setObject:@2 forKey:@"gender"];
                    }
                }


                // Save profile picture to Parse backend from Facebook.
                if (userData[@"id"]) {
                    NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", userData[@"id"]]];
                    PFFile *imageFile = [PFFile fileWithData:[NSData dataWithContentsOfURL:pictureURL]];
                    [[PFUser currentUser] setObject:imageFile forKey:@"picture"];
                }

                // Set bio from Facebook and set it in the Parse backend.
                if (userData[@"bio"]) {
                    [[PFUser currentUser]setObject:userData[@"bio"] forKey:@"bio"];
                }

                // Set age label from Facebook and set age in Parse backend.
                if (userData[@"birthday"]) {
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
                }


                // Get "interested in" from Facebook and set in Parse backend
                if (userData [@"interested_in"]) {
                    for (NSString *object in userData[@"interested_in"])
                    {
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

            }
            [[PFUser currentUser] saveInBackground];
        }];
    }
}







@end
