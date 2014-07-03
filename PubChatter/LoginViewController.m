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
#import <QuartzCore/QuartzCore.h>

@interface LoginViewController () <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end

@implementation LoginViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];

    NSLog(@"initWithCoder ran");

    PFSignUpViewController *signUpViewController = [PFSignUpViewController new];
    signUpViewController.delegate = self;
    self.signUpController = signUpViewController;

    self.delegate = self;

    //Set fields
    self.fields = PFLogInFieldsFacebook | PFLogInFieldsSignUpButton | PFLogInFieldsDefault;

    //Request Facebook permissions.
    self.facebookPermissions = @[@"public_profile", @"user_about_me", @"user_birthday", @"user_relationship_details"];

    return self;
}

-(void)viewDidLayoutSubviews
{
    NSLog(@"%@", self.signUpController);

    UIColor *green = [UIColor buttonColor];
    UIColor *white = [UIColor whiteColor];
    UIColor *black = [UIColor blackColor];
    UIColor *clear = [UIColor clearColor];

    //Set background picture.
    [self.logInView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"river"]]];

    //Set username field attributes.
    self.logInView.usernameField.backgroundColor = white;
    self.logInView.usernameField.layer.opacity = 0.6f;
    self.logInView.usernameField.textColor = black;
    self.logInView.usernameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"User Name" attributes:@{NSForegroundColorAttributeName: black}];
    self.logInView.usernameField.layer.cornerRadius = 5.0f;
    self.logInView.usernameField.layer.borderWidth = 2.0f;
    self.logInView.usernameField.layer.borderColor = [black CGColor];

    //Set password field attributes.
    self.logInView.passwordField.backgroundColor = white;
    self.logInView.passwordField.layer.opacity = 0.6f;
    self.logInView.passwordField.textColor = black;
    self.logInView.passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: black}];
    self.logInView.passwordField.layer.cornerRadius = 5.0f;
    self.logInView.passwordField.layer.borderWidth = 2.0f;
    self.logInView.passwordField.layer.borderColor = [black CGColor];

    //Set login dismiss button to unviewable
    self.logInView.dismissButton.alpha = 0.0;

    //Set login button
    [self.logInView.logInButton setBackgroundImage:[UIImage new] forState:UIControlStateNormal];
    [self.logInView.logInButton setBackgroundColor:clear];
    [self.logInView.logInButton setBackgroundImage:[UIImage new] forState:UIControlStateHighlighted];
    self.logInView.logInButton.layer.opacity = 0.9f;
    self.logInView.logInButton.layer.borderWidth = 2.0f;
    self.logInView.logInButton.layer.cornerRadius = 5.0;
    self.logInView.logInButton.layer.borderColor = [green CGColor];
    [self.logInView.logInButton setTitleColor:green forState:UIControlStateNormal];
    [self.logInView.logInButton setTitleColor:[UIColor buttonColor] forState:UIControlStateNormal];

    //Set signup button
    [self.logInView.signUpButton setBackgroundImage:[UIImage new] forState:UIControlStateNormal];
    [self.logInView.signUpButton setBackgroundColor:clear];
    [self.logInView.signUpButton setBackgroundImage:[UIImage new] forState:UIControlStateHighlighted];
    [self.logInView.signUpButton setBackgroundColor:clear];
    self.logInView.signUpButton.layer.borderWidth = 2.0f;
    self.logInView.signUpButton.layer.cornerRadius = 5.0;
    self.logInView.signUpButton.layer.borderColor = [green CGColor];
    [self.logInView.signUpButton setTitleColor:green forState:UIControlStateNormal];

    //Set "You can sign up with" text and "External login label"
    self.logInView.signUpLabel.textColor = [UIColor whiteColor];
    self.logInView.externalLogInLabel.textColor = [UIColor whiteColor];

    //Set logo
    self.logInView.logo = nil;

    //Set signup control style.

    //Set signup button
    [self.signUpController.signUpView.signUpButton setBackgroundImage:[UIImage new] forState:UIControlStateNormal];
    [self.signUpController.signUpView.signUpButton setBackgroundImage:[UIImage new] forState:UIControlStateHighlighted];
    [self.signUpController.signUpView.signUpButton setBackgroundColor:clear];
    self.signUpController.signUpView.signUpButton.layer.borderWidth = 2.0f;
    self.signUpController.signUpView.signUpButton.layer.cornerRadius = 5.0;
    self.signUpController.signUpView.signUpButton.layer.borderColor = [green CGColor];
    [self.signUpController.signUpView.signUpButton setTitleColor:green forState:UIControlStateNormal];

    //Set background picture.
    [self.signUpController.signUpView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"river"]]];

    //Set username field attributes.
    self.signUpController.signUpView.usernameField.backgroundColor = white;
    self.signUpController.signUpView.usernameField.layer.opacity = 0.6f;
    self.signUpController.signUpView.usernameField.textColor = black;
    self.signUpController.signUpView.usernameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Username" attributes:@{NSForegroundColorAttributeName: black}];
    self.signUpController.signUpView.usernameField.layer.cornerRadius = 5.0f;
    self.signUpController.signUpView.usernameField.layer.borderWidth = 2.0f;
    self.signUpController.signUpView.usernameField.layer.borderColor = [black CGColor];

    //Set email field attributes.
    self.signUpController.signUpView.emailField.backgroundColor = white;
    self.signUpController.signUpView.emailField.layer.opacity = 0.6f;
    self.signUpController.signUpView.emailField.textColor = black;
    self.signUpController.signUpView.emailField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: black}];
    self.signUpController.signUpView.emailField.layer.cornerRadius = 5.0f;
    self.signUpController.signUpView.emailField.layer.borderWidth = 2.0f;
    self.signUpController.signUpView.emailField.layer.borderColor = [black CGColor];

    //Set password field attributes.
    self.signUpController.signUpView.passwordField.backgroundColor = white;
    self.signUpController.signUpView.passwordField.layer.opacity = 0.6f;
    self.signUpController.signUpView.passwordField.textColor = black;
    self.signUpController.signUpView.passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: black}];
    self.signUpController.signUpView.passwordField.layer.cornerRadius = 5.0f;
    self.signUpController.signUpView.passwordField.layer.borderWidth = 2.0f;
    self.signUpController.signUpView.passwordField.layer.borderColor = [black CGColor];

    //Set login dismiss button to unviewable
    self.signUpController.signUpView.dismissButton.alpha = 1.0;

    //Set logo
    self.signUpController.signUpView.logo = nil;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"viewDidLoad ran");
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
    if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
    [self updateFacebookData];
    }
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

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self performSegueWithIdentifier:@"next" sender:self];


    //[self dismissModalViewControllerAnimated:YES]; // Dismiss the PFSignUpViewController
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
