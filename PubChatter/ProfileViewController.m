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
@property (strong, nonatomic) UILabel *backgroundView;
@property (strong, nonatomic) UILabel *imageEdge;
@property (strong, nonatomic) UIButton *logoutButton;


@property AppDelegate *appDelegate;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

-(void)didreceiveNotification:(NSNotification *)notification;

@end

@implementation ProfileViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didreceiveNotification:)
                                                 name:@"userEnteredBar"
                                               object:nil];

    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.scrollView.delegate = self;
//    [self getParseData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor clearColor];
    [self.bioTextView removeFromSuperview];
    [self.nameageLabel removeFromSuperview];
    [self.genderLabel removeFromSuperview];
    [self.interestedLabel removeFromSuperview];
    [self.favDrinkLabel removeFromSuperview];
    [self.aboutMeLabel removeFromSuperview];
    [self.backgroundView removeFromSuperview];
    [self.imageEdge removeFromSuperview];
    [self.logoutButton removeFromSuperview];

    [self getParseData];
}



-(void)addViewsToScrollView {
    CGFloat verticalOffset = 10.0;

    //Add imageview
    UIImageView *profileImageView = [[UIImageView alloc] init];
    profileImageView.frame = CGRectMake((self.scrollView.frame.size.width/2) -75, verticalOffset, 150, 150);
    profileImageView.image = self.profileImage;
    profileImageView.layer.masksToBounds = YES;
    profileImageView.layer.cornerRadius = 5.0f;
    [self.scrollView addSubview:profileImageView];

    // Add image borderview
    self.imageEdge = [[UILabel alloc] init];
    self.imageEdge.frame = CGRectMake((self.scrollView.frame.size.width/2) -76, verticalOffset - 1, 152, 152);
    self.imageEdge.backgroundColor = [UIColor clearColor];
//    self.imageEdge.layer.borderColor = [[UIColor whiteColor] CGColor];
//    self.imageEdge.layer.borderWidth = 1.0f;
    [self.scrollView addSubview:self.imageEdge];

    verticalOffset = verticalOffset + profileImageView.frame.size.height + 10;

    //Add name label
    self.nameageLabel = [[UILabel alloc] init];
    self.nameageLabel.frame = CGRectMake((self.scrollView.frame.size.width /2) - 140, verticalOffset, 280, 30);
    self.nameageLabel.text = [NSString stringWithFormat:@"%@, %@", self.name, self.age];
    self.nameageLabel.textAlignment = NSTextAlignmentCenter;
    self.nameageLabel.textColor = [UIColor nameColor];
    [self.nameageLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:17]];
    [self.scrollView addSubview:self.nameageLabel];
    verticalOffset = verticalOffset + self.nameageLabel.frame.size.height + 10;

    //Add gender label
    self.genderLabel = [[UILabel alloc] init];
    self.genderLabel.frame = CGRectMake((self.scrollView.frame.size.width /2) - 140, verticalOffset, 280, 30);
    self.genderLabel.text = self.gender;
    self.genderLabel.textAlignment = NSTextAlignmentCenter;
    self.genderLabel.textColor = [UIColor whiteColor];
    [self.genderLabel setFont:[UIFont systemFontOfSize:17.0]];
    [self.scrollView addSubview:self.genderLabel];
    verticalOffset = verticalOffset + self.genderLabel.frame.size.height + 10;

    //Add about me label
    self.aboutMeLabel = [[UILabel alloc] init];
    self.aboutMeLabel.frame = CGRectMake((self.scrollView.frame.size.width /2) - 140, verticalOffset, 280, 30);
    self.aboutMeLabel.text = [NSString stringWithFormat:@"About %@", self.name];
    self.aboutMeLabel.textAlignment = NSTextAlignmentCenter;
    self.aboutMeLabel.textColor = [UIColor whiteColor];
    [self.scrollView addSubview:self.aboutMeLabel];
    verticalOffset = verticalOffset + self.aboutMeLabel.frame.size.height;

    //Add bio textView
    self.bioTextView = [[UITextView alloc] init];
    self.bioTextView.frame = CGRectMake((self.scrollView.frame.size.width /2) - 140, verticalOffset, 280, 70);
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
    self.interestedLabel.text = self.sexualOrientation;
    self.interestedLabel.textAlignment = NSTextAlignmentCenter;
    self.interestedLabel.textColor = [UIColor whiteColor];
    [self.scrollView addSubview:self.interestedLabel];
    verticalOffset = verticalOffset + self.interestedLabel.frame.size.height + 10;

    //Add Favorite drink label
    self.favDrinkLabel = [[UILabel alloc] init];
    self.favDrinkLabel.frame = CGRectMake((self.scrollView.frame.size.width /2) - 140, verticalOffset, 280, 30);
    self.favDrinkLabel.text = [NSString stringWithFormat:@"Favorite drink: %@", self.favDrink];
    self.favDrinkLabel.textAlignment = NSTextAlignmentCenter;
    self.favDrinkLabel.textColor = [UIColor whiteColor];
    [self.scrollView addSubview:self.favDrinkLabel];
    verticalOffset = verticalOffset + self.favDrinkLabel.frame.size.height + 15;

    //Add logout button
    self.logoutButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.logoutButton addTarget:self
                          action:@selector(logUserOut:)
                forControlEvents:UIControlEventTouchUpInside];
    [self.logoutButton setTitle:@"Logout" forState:UIControlStateNormal];
    self.logoutButton.frame = CGRectMake((self.scrollView.frame.size.width /2) - 40, verticalOffset, 80, 30);
    [self.logoutButton setTitleColor:[UIColor buttonColor] forState:UIControlStateNormal];
    [self.logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.scrollView addSubview:self.logoutButton];
    verticalOffset = verticalOffset + self.logoutButton.frame.size.height + 15;

    //Add background view
    self.backgroundView = [[UILabel alloc] init];
    self.backgroundView.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, verticalOffset);
    self.backgroundView.backgroundColor = [UIColor clearColor];
    [self.scrollView insertSubview:self.backgroundView atIndex:0];

    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, verticalOffset);
    self.scrollView.contentMode = UIViewContentModeScaleAspectFit;
    [self setStyle];
}

-(void)logUserOut:(id)sender
{
    self.logoutButton.titleLabel.textColor = [UIColor whiteColor];
    [PFUser logOut];
    //logout of parse
    NSLog(@"logout button workin");
    [self performSegueWithIdentifier:@"logoutSegue" sender:self];
}

-(void)getParseData
{

    //Get name text.
    self.name = [[PFUser currentUser]objectForKey:@"name"];

    //Get bio text.
    if ([[PFUser currentUser]objectForKey:@"bio"]) {

        self.bioText = [[PFUser currentUser]objectForKey:@"bio"];
    }
    else
    {
        self.bioText = @"";
    }

    //Get favorite drink.
    if ([[PFUser currentUser]objectForKey:@"favoriteDrink"])
    {
        self.favDrink = [[PFUser currentUser]objectForKey:@"favoriteDrink"];
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
         self.age = @"";
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
         self.sexualOrientation = @"Bisexual";
     }
     else
     {
         self.sexualOrientation = @"";
     }

    //Get user image.
    PFFile *file = [[PFUser currentUser]objectForKey:@"picture"];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
     {
         self.profileImage = [UIImage imageWithData:data];
         [self addViewsToScrollView];
     }];
}

#pragma mark - Segue Methods

- (IBAction)unwindSegueToProfileViewController:(UIStoryboardSegue *)sender
{

}
#pragma mark - NSNotification Center
-(void)didreceiveNotification:(NSNotification *)notification
{
    NSLog(@"notification in profile vc %@",[notification.userInfo objectForKey:@"barName"]);
    self.navigationItem.title = [notification.userInfo objectForKey:@"barName"];
}

#pragma mark - Styling method
-(void)setStyle
{
    //Style nameagelabel
    self.navigationController.navigationBar.backgroundColor = [UIColor navBarColor];
}

@end
