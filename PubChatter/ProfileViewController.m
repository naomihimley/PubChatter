//
//  ProfileViewController.m
//  PubChatter
//
//  Created by David Warner on 6/13/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import "ProfileViewController.h"
#import "AppDelegate.h"
#import "UIColor+DesignColors.h"
#import <QuartzCore/QuartzCore.h>
#import "BarDetailViewController.h"

@interface ProfileViewController ()<CLLocationManagerDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, UIScrollViewDelegate>
@property (strong, nonatomic) UIImage *profileImage;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *gender;
@property (strong, nonatomic) NSString *bioText;
@property (strong, nonatomic) NSString *age;
@property (strong, nonatomic) NSString *sexualOrientation;
@property (strong, nonatomic) NSString *favDrink;
@property (strong, nonatomic) UITextView *bioTextView;
@property (strong, nonatomic) UILabel *nameageLabel;
@property (strong, nonatomic) UILabel *genderLabel;
@property (strong, nonatomic) UILabel *interestedLabel;
@property (strong, nonatomic) UILabel *favDrinkLabel;
@property (strong, nonatomic) UILabel *aboutMeLabel;
@property (strong, nonatomic) UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIButton *editButtonOutlet;

@property (strong, nonatomic) UILabel *completeProfile;


@property AppDelegate *appDelegate;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

-(void)didreceiveNotification:(NSNotification *)notification;

@end

@implementation ProfileViewController
- (void)viewDidLoad
{
    [super viewDidLoad];

    NSLog(@"ProfileVC Load");

    [self.editButtonOutlet setTitleColor:[UIColor buttonColor] forState:UIControlStateNormal];
    [self.editButtonOutlet setTitleColor:[UIColor buttonColor] forState:UIControlStateHighlighted];
    [self.editButtonOutlet setTitleColor:[UIColor buttonColor] forState:UIControlStateSelected];
    self.editButtonOutlet.layer.cornerRadius = 5.0f;
    self.editButtonOutlet.layer.masksToBounds = YES;
    self.editButtonOutlet.layer.borderWidth = 2.0f;
    self.editButtonOutlet.layer.borderColor= [[UIColor buttonColor]CGColor];
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.scrollView.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.nameageLabel removeFromSuperview];
    [self.genderLabel removeFromSuperview];
    [self.interestedLabel removeFromSuperview];
    [self.favDrinkLabel removeFromSuperview];
    [self.aboutMeLabel removeFromSuperview];
    [self.bioTextView removeFromSuperview];

    NSLog(@"I ran");
    [self getParseData];

    // Possible alertview, if the user doesn't have a name????
//    NSLog(@"User's name: %@", [[PFUser currentUser] objectForKey:@"name"]);
//    NSString *usersname = [[PFUser currentUser] objectForKey:@"name"];
//    if (usersname.length < 1) {
//        NSLog(@"%@", [[PFUser currentUser] objectForKey:@"name"]);
//        UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:@"Select the edit button to complete your profile" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alert show];
//    }
}


-(void)addViewsToScrollView {
    CGFloat verticalOffset = 10.0;

    //Add imageview
    UIImageView *profileImageView = [[UIImageView alloc] init];
    profileImageView.frame = CGRectMake((self.scrollView.frame.size.width/2) -100, verticalOffset, 200, 200);
    profileImageView.image = self.profileImage;
    profileImageView.layer.cornerRadius = 5.0f;
    profileImageView.layer.masksToBounds = YES;
    [self.scrollView addSubview:profileImageView];

    verticalOffset = verticalOffset + profileImageView.frame.size.height + 10;

    //Add name label
    self.nameageLabel = [[UILabel alloc] init];
    self.nameageLabel.frame = CGRectMake((self.scrollView.frame.size.width /2) - 140, verticalOffset, 280, 30);
    if (self.name.length < 1) {
        self.name = @"Name";
    if (self.age.length < 1)
        self.age = @"Age";
    }
    self.nameageLabel.text = [NSString stringWithFormat:@"%@, %@", self.name, self.age];
    self.nameageLabel.textAlignment = NSTextAlignmentCenter;
    self.nameageLabel.textColor = [UIColor nameColor];
    [self.nameageLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:20]];
    [self.scrollView addSubview:self.nameageLabel];

    verticalOffset = verticalOffset + self.nameageLabel.frame.size.height + 10;

    //Add gender label
    self.genderLabel = [[UILabel alloc] init];
    self.genderLabel.frame = CGRectMake((self.scrollView.frame.size.width /2) - 140, verticalOffset, 280, 30);
    self.genderLabel.text = self.gender;

    if (self.gender.length < 1) {
        self.gender = @"Gender:";
    }
    self.genderLabel.text = self.gender;
    self.genderLabel.textAlignment = NSTextAlignmentCenter;
    self.genderLabel.textColor = [UIColor whiteColor];
    [self.genderLabel setFont:[UIFont systemFontOfSize:16.0]];
    [self.scrollView addSubview:self.genderLabel];
    verticalOffset = verticalOffset + self.genderLabel.frame.size.height + 10;

    //Add about me label
    self.aboutMeLabel = [[UILabel alloc] init];
    self.aboutMeLabel.frame = CGRectMake((self.scrollView.frame.size.width /2) - 140, verticalOffset, 280, 30);
    self.aboutMeLabel.text = [NSString stringWithFormat:@"About %@", self.name];
    self.aboutMeLabel.textAlignment = NSTextAlignmentCenter;
    [self.aboutMeLabel setFont:[UIFont systemFontOfSize:16.0]];
    self.aboutMeLabel.textColor = [UIColor whiteColor];
    [self.scrollView addSubview:self.aboutMeLabel];
    verticalOffset = verticalOffset + self.aboutMeLabel.frame.size.height;

    //Add bio textView
    self.bioTextView = [[UITextView alloc] init];
    self.bioTextView.frame = CGRectMake((self.scrollView.frame.size.width /2) - 140, verticalOffset, 280, 70);
    if (self.bioText.length < 1) {
        self.bioText = @"No bio provided";
    }
    self.bioTextView.text = self.bioText;
    self.bioTextView.editable = NO;
    self.bioTextView.textAlignment = NSTextAlignmentCenter;
    self.bioTextView.textColor = [UIColor whiteColor];
    self.bioTextView.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:self.bioTextView];
    verticalOffset = verticalOffset + self.bioTextView.frame.size.height + 10;

    //Add interested label
    self.interestedLabel = [[UILabel alloc] init];
    self.interestedLabel.frame = CGRectMake((self.scrollView.frame.size.width /2) - 140, verticalOffset, 280, 30);
    if (self.sexualOrientation.length < 1) {
        self.sexualOrientation = @"Interested In:";
    }
    self.interestedLabel.text = self.sexualOrientation;
    [self.interestedLabel setFont:[UIFont systemFontOfSize:16.0]];
    self.interestedLabel.textAlignment = NSTextAlignmentCenter;
    self.interestedLabel.textColor = [UIColor whiteColor];
    [self.scrollView addSubview:self.interestedLabel];
    verticalOffset = verticalOffset + self.interestedLabel.frame.size.height + 10;

    //Add Favorite drink label
    self.favDrinkLabel = [[UILabel alloc] init];
    self.favDrinkLabel.frame = CGRectMake((self.scrollView.frame.size.width /2) - 140, verticalOffset, 280, 30);
    if (self.favDrink.length < 1) {
        self.favDrink = @"";
    }
    self.favDrinkLabel.text = [NSString stringWithFormat:@"Favorite drink: %@", self.favDrink];
    self.favDrinkLabel.textAlignment = NSTextAlignmentCenter;
    self.favDrinkLabel.textColor = [UIColor whiteColor];
    [self.favDrinkLabel setFont:[UIFont systemFontOfSize:16.0]];
    [self.scrollView addSubview:self.favDrinkLabel];
    verticalOffset = verticalOffset + self.favDrinkLabel.frame.size.height + 15;

    //Add logout button
    self.logoutButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.logoutButton addTarget:self
                          action:@selector(logUserOut:)
                forControlEvents:UIControlEventTouchUpInside];
    [self.logoutButton setTitle:@"Logout" forState:UIControlStateNormal];
    self.logoutButton.frame = CGRectMake((self.scrollView.frame.size.width /2) - 75, verticalOffset, 150, 30);
    [self.logoutButton setTitleColor:[UIColor buttonColor] forState:UIControlStateNormal];
    [self.logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    self.logoutButton.layer.borderWidth = 2.0f;
    self.logoutButton.layer.cornerRadius = 5.0f;
    self.logoutButton.layer.borderColor = [[UIColor buttonColor] CGColor];
    [self.scrollView addSubview:self.logoutButton];

    verticalOffset = verticalOffset + self.logoutButton.frame.size.height + 15;

    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, verticalOffset);
    self.scrollView.contentMode = UIViewContentModeScaleAspectFit;
    [self setStyle];

    NSLog(@"label: %@", self.nameageLabel.text);
    NSLog(@"label: %@", self.genderLabel.text);
    NSLog(@"label: %@", self.favDrinkLabel.text);
    NSLog(@"label: %@", self.interestedLabel.text);
    NSLog(@"label: %@", self.bioTextView.text);
}

-(void)logUserOut:(id)sender
{
    self.logoutButton.titleLabel.textColor = [UIColor whiteColor];
    [PFUser logOut];
    //logout of parse
    [self performSegueWithIdentifier:@"logoutSegue" sender:self];
}

-(void)getParseData
{
    //Get name text.
    if ([[PFUser currentUser]objectForKey:@"name"] != nil) {
        self.name = [[PFUser currentUser]objectForKey:@"name"];
    }
    else {
        self.name = @"Name";
    }

    //Get bio text.
    if ([[PFUser currentUser]objectForKey:@"bio"] != nil) {

        self.bioText = [[PFUser currentUser]objectForKey:@"bio"];
    }
    else
    {
        self.bioText = @"No bio info";
    }

    //Get favorite drink.
    if ([[PFUser currentUser]objectForKey:@"favoriteDrink"] != nil)
    {
        self.favDrink = [[PFUser currentUser]objectForKey:@"favoriteDrink"];
        NSLog(@"%@", self.favDrink);
    }
    else
    {
        self.favDrink = @"No drink info";
        NSLog(@"No drink value returned");
    }

    //Get gender.
    if ([[[PFUser currentUser]objectForKey:@"gender"] isEqual:@0])
     {
         self.gender = @"Female";
     }
     else if ([[[PFUser currentUser]objectForKey:@"gender"] isEqual:@1])
     {
         self.gender = @"Male";
     }
     else if ([[[PFUser currentUser]objectForKey:@"gender"] isEqual:@2])
     {
         self.gender = @"Other";
     }

    //Get age.
    if ([[PFUser currentUser]objectForKey:@"age"])
    {
        NSNumber *age = [[PFUser currentUser]objectForKey:@"age"];
        self.age = [NSString stringWithFormat:@"%@", age];
    }
     else
     {
         self.age = @"Age";
     }

    //Get sexual orientation.
     if ([[[PFUser currentUser]objectForKey:@"sexualOrientation"] isEqual:@0])
     {
         self.sexualOrientation = @"Interested in: Men";
     }
     else if ([[[PFUser currentUser]objectForKey:@"sexualOrientation"] isEqual:@1])
     {
         self.sexualOrientation = @"Interested in: Women";
     }
     else if ([[[PFUser currentUser]objectForKey:@"sexualOrientation"] isEqual:@2])
     {
         self.sexualOrientation = @"Interested in: Other";
     }
    NSLog(@"string: %@", self.name);
    NSLog(@"string: %@", self.gender);
    NSLog(@"string: %@", self.favDrink);
    NSLog(@"string: %@", self.sexualOrientation);
    NSLog(@"string: %@", self.bioText);

    if ([[PFUser currentUser]objectForKey:@"picture"] != nil) {
        PFFile *file = [[PFUser currentUser]objectForKey:@"picture"];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
         {
             self.profileImage = [UIImage imageWithData:data];
             [self addViewsToScrollView];
         }];
        }
    else {
        self.profileImage = [UIImage imageNamed:@"profile-placeholder"];
        [self addViewsToScrollView];
    }
}

#pragma mark - Segue Methods

- (IBAction)unwindSegueToProfileViewController:(UIStoryboardSegue *)sender
{

}

#pragma mark - Styling method
-(void)setStyle
{
    //Style nameagelabel
    self.navigationController.navigationBar.backgroundColor = [UIColor navBarColor];
    self.view.backgroundColor = [UIColor clearColor];
}

@end
