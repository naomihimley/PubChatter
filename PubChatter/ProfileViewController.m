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

@interface ProfileViewController ()<CLLocationManagerDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, UIScrollViewDelegate, UINavigationBarDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *gender;
@property (strong, nonatomic) NSString *bioText;
@property (strong, nonatomic) NSString *age;
@property (strong, nonatomic) NSString *sexualOrientation;
@property (strong, nonatomic) NSString *favDrink;
@property (strong, nonatomic) NSMutableArray *imagesArray;

@property (strong, nonatomic) UIImage *profileImage;
@property (strong, nonatomic) UITextView *bioTextView;
@property (strong, nonatomic) UILabel *nameageLabel;
@property (strong, nonatomic) UILabel *genderLabel;
@property (strong, nonatomic) UILabel *interestedLabel;
@property (strong, nonatomic) UILabel *favDrinkLabel;
@property (strong, nonatomic) UILabel *aboutMeLabel;
@property (strong, nonatomic) UIButton *logoutButton;
@property (strong, nonatomic) UIButton *pictureButton;
@property (strong, nonatomic) UIImageView *profileImageView;
@property (strong, nonatomic) UIImageView *largeImageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIPageControl *pageControl;

@property BOOL pictureButtonPressed;
@property CGFloat verticalOffset;
@property NSInteger swipeIndex;
@property (weak, nonatomic) IBOutlet UIButton *editButtonOutlet;
@property AppDelegate *appDelegate;

-(void)didreceiveNotification:(NSNotification *)notification;

@end

@implementation ProfileViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.delegate = self;
    self.view.backgroundColor = [UIColor clearColor];
//    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"river"]];
    [self.editButtonOutlet setTitleColor:[UIColor buttonColor] forState:UIControlStateNormal];
    [self.editButtonOutlet setTitleColor:[UIColor buttonColor] forState:UIControlStateHighlighted];
    [self.editButtonOutlet setTitleColor:[UIColor buttonColor] forState:UIControlStateSelected];
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.scrollView.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated
{
    self.pictureButtonPressed = NO;
    self.swipeIndex = 0;

    [super viewWillAppear:YES];
    [self.nameageLabel removeFromSuperview];
    [self.genderLabel removeFromSuperview];
    [self.interestedLabel removeFromSuperview];
    [self.favDrinkLabel removeFromSuperview];
    [self.aboutMeLabel removeFromSuperview];
    [self.bioTextView removeFromSuperview];
    [self.profileImageView removeFromSuperview];
    [self.logoutButton removeFromSuperview];
    [self.largeImageView removeFromSuperview];
    [self.pageControl removeFromSuperview];
    [self setStyle];

    [self getParseData];
}

-(void)addViewsToScrollView {

    self.verticalOffset = 0.0;

    if (self.pictureButtonPressed) {
        self.swipeIndex = 0;
        NSLog(@"images array count: %lu", (unsigned long)self.imagesArray.count);

        //Add large imageview

        self.largeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.verticalOffset, self.view.frame.size.width, self.view.frame.size.width)];
        [self.largeImageView setUserInteractionEnabled:YES];

        self.largeImageView.image = [self.imagesArray objectAtIndex:self.swipeIndex];

        UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
        UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissLargePics:)];

        // Setting the swipe direction.
        [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
        [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];

        //Add Page Control to navbar
        self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(self.navigationController.navigationBar.frame.size.width / 2 - 50, self.navigationController.navigationBar.frame.origin.y, 100, 20)];
        self.pageControl.numberOfPages = self.imagesArray.count;
        self.pageControl.currentPageIndicatorTintColor = [UIColor buttonColor];
        UINavigationController *navCon  = (UINavigationController*) [self.navigationController.viewControllers objectAtIndex:0];
        navCon.navigationItem.title = @"";
        self.editButtonOutlet.enabled = NO;
        self.editButtonOutlet.titleLabel.textColor = [UIColor clearColor];

        // Adding stuff to the superview
        [self.largeImageView addGestureRecognizer:swipeLeft];
        [self.largeImageView addGestureRecognizer:swipeRight];
        [self.view addGestureRecognizer:tap];
        [self.scrollView addSubview:self.largeImageView];
        [self.navigationController.navigationBar addSubview:self.pageControl];

        self.verticalOffset = self.verticalOffset + self.largeImageView.frame.size.height + 10;
    }

    else {

    self.verticalOffset = 30.0;
        
    //Add imageview
    self.profileImageView = [[UIImageView alloc] init];
    self.profileImageView.frame = CGRectMake((self.scrollView.frame.size.width/2) - 100, self.verticalOffset, 200, 200);
    self.profileImageView.image = self.profileImage;
    self.profileImageView.layer.cornerRadius = 5.0f;
    self.profileImageView.layer.masksToBounds = YES;
    [self.scrollView addSubview:self.profileImageView];

    self.pictureButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.pictureButton addTarget:self
                     action:@selector(getUserPictures:)
           forControlEvents:UIControlEventTouchUpInside];
    self.pictureButton.frame = CGRectMake((self.scrollView.frame.size.width/2) - 75, self.verticalOffset, 150, 150);
    [self.pictureButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    [self.pictureButton setBackgroundColor:[UIColor clearColor]];
    [self.scrollView addSubview:self.pictureButton];

    self.verticalOffset = self.verticalOffset + self.profileImageView.frame.size.height + 10;
    }

    //Add name label
    self.nameageLabel = [[UILabel alloc] init];
    self.nameageLabel.frame = CGRectMake((self.scrollView.frame.size.width /2) - 140, self.verticalOffset, 280, 30);
    if (self.name.length < 1) {
        self.nameageLabel.text = @"Please Complete Profile";
        }
    else {
        self.nameageLabel.text = [NSString stringWithFormat:@"%@, %@", self.name, self.age];
    }
    self.nameageLabel.textAlignment = NSTextAlignmentCenter;
    self.nameageLabel.textColor = [UIColor nameColor];
    [self.nameageLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:20]];
    [self.scrollView addSubview:self.nameageLabel];

    self.verticalOffset = self.verticalOffset + self.nameageLabel.frame.size.height + 10;

    //Add gender label
    self.genderLabel = [[UILabel alloc] init];
    self.genderLabel.frame = CGRectMake((self.scrollView.frame.size.width /2) - 140, self.verticalOffset, 280, 30);
    self.genderLabel.text = self.gender;
    if (self.gender.length < 1) {
        self.gender = @"Gender:";
    }
    self.genderLabel.text = self.gender;
    self.genderLabel.textAlignment = NSTextAlignmentCenter;
    self.genderLabel.textColor = [UIColor whiteColor];
    [self.genderLabel setFont:[UIFont systemFontOfSize:16.0]];
    [self.scrollView addSubview:self.genderLabel];
    self.verticalOffset = self.verticalOffset + self.genderLabel.frame.size.height + 10;

    //Add about me label
    self.aboutMeLabel = [[UILabel alloc] init];
    self.aboutMeLabel.frame = CGRectMake((self.scrollView.frame.size.width /2) - 140, self.verticalOffset, 280, 30);
    if ([self.name  isEqual: @"Name"]) {
        self.aboutMeLabel.text = @"About Me";
    }
    else {
        self.aboutMeLabel.text = [NSString stringWithFormat:@"About %@", self.name];
    }
    self.aboutMeLabel.textAlignment = NSTextAlignmentCenter;
    [self.aboutMeLabel setFont:[UIFont systemFontOfSize:16.0]];
    self.aboutMeLabel.textColor = [UIColor whiteColor];
    [self.scrollView addSubview:self.aboutMeLabel];
    self.verticalOffset = self.verticalOffset + self.aboutMeLabel.frame.size.height;

    //Add bio textView
    self.bioTextView = [[UITextView alloc] init];
    self.bioTextView.frame = CGRectMake((self.scrollView.frame.size.width /2) - 140, self.verticalOffset, 280, 55);
    if (self.bioText.length < 1) {
        self.bioText = @"No bio provided";
    }
    self.bioTextView.text = self.bioText;
    self.bioTextView.editable = NO;
    self.bioTextView.textAlignment = NSTextAlignmentCenter;
    self.bioTextView.textColor = [UIColor whiteColor];
    self.bioTextView.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:self.bioTextView];
    self.verticalOffset = self.verticalOffset + self.bioTextView.frame.size.height + 5;

    //Add interested label
    self.interestedLabel = [[UILabel alloc] init];
    self.interestedLabel.frame = CGRectMake((self.scrollView.frame.size.width /2) - 140, self.verticalOffset, 280, 30);
    if (self.sexualOrientation.length < 1) {
        self.sexualOrientation = @"Interested In:";
    }
    self.interestedLabel.text = self.sexualOrientation;
    [self.interestedLabel setFont:[UIFont systemFontOfSize:16.0]];
    self.interestedLabel.textAlignment = NSTextAlignmentCenter;
    self.interestedLabel.textColor = [UIColor whiteColor];
    [self.scrollView addSubview:self.interestedLabel];
    self.verticalOffset = self.verticalOffset + self.interestedLabel.frame.size.height + 10;

    //Add Favorite drink label
    self.favDrinkLabel = [[UILabel alloc] init];
    self.favDrinkLabel.frame = CGRectMake((self.scrollView.frame.size.width /2) - 140, self.verticalOffset, 280, 30);
    if (self.favDrink.length < 1) {
        self.favDrink = @"";
    }
    self.favDrinkLabel.text = [NSString stringWithFormat:@"Favorite drink: %@", self.favDrink];
    self.favDrinkLabel.textAlignment = NSTextAlignmentCenter;
    self.favDrinkLabel.textColor = [UIColor whiteColor];
    [self.favDrinkLabel setFont:[UIFont systemFontOfSize:16.0]];
    [self.scrollView addSubview:self.favDrinkLabel];
    self.verticalOffset = self.verticalOffset + self.favDrinkLabel.frame.size.height + 15;

    //Add logout button
    self.logoutButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.logoutButton addTarget:self
                          action:@selector(logUserOut:)
                forControlEvents:UIControlEventTouchUpInside];
    [self.logoutButton setTitle:@"Logout" forState:UIControlStateNormal];
    self.logoutButton.frame = CGRectMake((self.scrollView.frame.size.width /2) - 75, self.verticalOffset, 150, 30);
    [self.logoutButton setTitleColor:[UIColor buttonColor] forState:UIControlStateNormal];
    [self.logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    self.logoutButton.layer.borderWidth = 2.0f;
    self.logoutButton.layer.cornerRadius = 5.0f;
    self.logoutButton.layer.borderColor = [[UIColor buttonColor] CGColor];
    [self.scrollView addSubview:self.logoutButton];

    self.verticalOffset = self.verticalOffset + self.logoutButton.frame.size.height + 15;

    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.verticalOffset);
    self.scrollView.contentMode = UIViewContentModeScaleAspectFit;
}

-(void)logUserOut:(id)sender
{
    [[self.appDelegate beaconRegionManager]logout];
    self.logoutButton.titleLabel.textColor = [UIColor whiteColor];
    [PFUser logOut];
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
    }
    else
    {
        self.favDrink = @"No drink info";
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

    self.imagesArray = [NSMutableArray new];

    if ([[PFUser currentUser]objectForKey:@"picture"] != nil) {
        PFFile *file = [[PFUser currentUser]objectForKey:@"picture"];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
         {
             self.profileImage = [UIImage imageWithData:data];
             [self.imagesArray addObject:self.profileImage];
             [self getArrayOfImages];
             [self addViewsToScrollView];
         }];
        }
    else {
        self.profileImage = [UIImage imageNamed:@"profile-placeholder"];
        [self addViewsToScrollView];
    }
}

-(void)getArrayOfImages
{
    NSArray *tempArray = [[PFUser currentUser] objectForKey:@"imagesArray"];

    if (tempArray) {
        for (PFFile *file in tempArray) {
            [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (data) {
                    UIImage *image = [UIImage imageWithData:data];
                    [self.imagesArray addObject:image];
                    NSLog(@"images array count: %lu", (unsigned long)self.imagesArray.count);
                }
            }];
        }
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
    UINavigationController *navCon  = (UINavigationController*) [self.navigationController.viewControllers objectAtIndex:0];
        navCon.navigationItem.title = @"Profile";
    self.editButtonOutlet.enabled = YES;
    self.editButtonOutlet.titleLabel.textColor = [UIColor buttonColor];
}

-(void)getUserPictures:(id)sender
{
    self.pictureButtonPressed = YES;

    [self.nameageLabel removeFromSuperview];
    [self.genderLabel removeFromSuperview];
    [self.interestedLabel removeFromSuperview];
    [self.favDrinkLabel removeFromSuperview];
    [self.aboutMeLabel removeFromSuperview];
    [self.bioTextView removeFromSuperview];
    [self.profileImageView removeFromSuperview];
    [self.logoutButton removeFromSuperview];
    [self.pageControl removeFromSuperview];
    [self setStyle];

    [self addViewsToScrollView];
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)swipe {

    if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
        if (self.swipeIndex == self.imagesArray.count -1) {
            NSLog(@"Swipe Index = %ld", (long)self.swipeIndex);
        }
        else {
            self.swipeIndex += 1;
            self.largeImageView.image = [self.imagesArray objectAtIndex:self.swipeIndex];
            NSLog(@"Swipe Index = %ld", (long)self.swipeIndex);
            self.pageControl.currentPage = self.swipeIndex;
        }
    }

    if (swipe.direction == UISwipeGestureRecognizerDirectionRight) {
        if (self.swipeIndex == 0) {
            NSLog(@"Swipe Index = %ld", (long)self.swipeIndex);
        }
        else {
            self.swipeIndex -= 1;
            self.largeImageView.image = [self.imagesArray objectAtIndex:self.swipeIndex];
            NSLog(@"Swipe Index = %ld", (long)self.swipeIndex);
            self.pageControl.currentPage = self.swipeIndex;
        }
    }
}

-(void)dismissLargePics:(id)sender
{
    self.pictureButtonPressed = NO;

    [self.nameageLabel removeFromSuperview];
    [self.genderLabel removeFromSuperview];
    [self.interestedLabel removeFromSuperview];
    [self.favDrinkLabel removeFromSuperview];
    [self.aboutMeLabel removeFromSuperview];
    [self.bioTextView removeFromSuperview];
    [self.profileImageView removeFromSuperview];
    [self.logoutButton removeFromSuperview];
    [self.largeImageView removeFromSuperview];
    [self.pageControl removeFromSuperview];
    [self setStyle];

    [self addViewsToScrollView];
}





@end










