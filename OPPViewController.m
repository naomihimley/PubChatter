//
//  OPPViewController.m
//  PubChatter
//
//  Created by Richard Fellure on 6/16/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import "OPPViewController.h"
#import "AppDelegate.h"
#import "ChatBoxViewController.h"
#import "UIColor+DesignColors.h"
#import <QuartzCore/QuartzCore.h>

@interface OPPViewController ()<UIAlertViewDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) UIImage *profileImage;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *gender;
@property (strong, nonatomic) NSString *bioText;
@property (strong, nonatomic) NSString *age;
@property (strong, nonatomic) NSString *sexualOrientation;
@property (strong, nonatomic) NSString *favDrink;
@property (strong, nonatomic) NSMutableArray *imagesArray;

@property (strong, nonatomic) UITextView *bioTextView;
@property (strong, nonatomic) UILabel *nameageLabel;
@property (strong, nonatomic) UILabel *genderLabel;
@property (strong, nonatomic) UILabel *ageLabel;
@property (strong, nonatomic) UILabel *interestedLabel;
@property (strong, nonatomic) UILabel *favDrinkLabel;
@property (strong, nonatomic) UILabel *aboutMeLabel;
@property (weak, nonatomic) IBOutlet UIView *fakeNavBar;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *largeImageView;
@property (strong, nonatomic) UIImageView *profileImageView;
@property (strong, nonatomic) UIButton *pictureButton;
@property (strong, nonatomic) UIPageControl *pageControl;

@property BOOL pictureButtonPressed;
@property CGFloat verticalOffset;
@property NSInteger swipeIndex;
@property AppDelegate *appDelegate;
@property (weak, nonatomic) IBOutlet UIButton *backButtonOutlet;
-(void)receivedInvitationForConnection: (NSNotification *)notification;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation OPPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.chatArray = [NSMutableArray array];
    self.chatDictionaryArray = [NSMutableArray array];
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receivedInvitationForConnection:) name:@"MCReceivedInvitation" object:nil];
    self.scrollView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.pictureButtonPressed = NO;
    self.swipeIndex = 0;

    self.activityIndicator.hidden = NO;
    [self.nameageLabel removeFromSuperview];
    [self.genderLabel removeFromSuperview];
    [self.interestedLabel removeFromSuperview];
    [self.favDrinkLabel removeFromSuperview];
    [self.aboutMeLabel removeFromSuperview];
    [self.bioTextView removeFromSuperview];
    [self.profileImageView removeFromSuperview];
    [self.largeImageView removeFromSuperview];
    
    [self getPersonalData];
}


-(void)addViewsToScrollView {

    self.verticalOffset = 0.0;

    if (self.pictureButtonPressed) {

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

        // Adding views and gestures to superview
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
    self.profileImageView.frame = CGRectMake((self.scrollView.frame.size.width/2) -100, self.verticalOffset, 200, 200);
    self.profileImageView.image = self.profileImage;
    self.profileImageView.layer.cornerRadius = 5.0f;
    self.profileImageView.layer.masksToBounds = YES;
    [self.scrollView addSubview:self.profileImageView];

    //Add tap-able button on picture that shows the larger pictures.
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
    self.nameageLabel.text = [NSString stringWithFormat:@"%@, %@", self.name, self.age];
    self.nameageLabel.textAlignment = NSTextAlignmentCenter;
    self.nameageLabel.textColor = [UIColor nameColor];
    [self.nameageLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:20]];
    [self.scrollView addSubview:self.nameageLabel];
    self.verticalOffset = self.verticalOffset + self.nameageLabel.frame.size.height + 10;

    //Add gender label
    self.genderLabel = [[UILabel alloc] init];
    self.genderLabel.frame = CGRectMake((self.scrollView.frame.size.width /2) - 140, self.verticalOffset, 280, 30);
    self.genderLabel.text = self.gender;
    self.genderLabel.textAlignment = NSTextAlignmentCenter;
    self.genderLabel.textColor = [UIColor whiteColor];
    [self.genderLabel setFont:[UIFont systemFontOfSize:16.0]];
    [self.scrollView addSubview:self.genderLabel];
    self.verticalOffset = self.verticalOffset + self.genderLabel.frame.size.height + 10;

    //Add about me label
    self.aboutMeLabel = [[UILabel alloc] init];
    self.aboutMeLabel.frame = CGRectMake((self.scrollView.frame.size.width /2) - 140, self.verticalOffset, 280, 30);
    self.aboutMeLabel.text = [NSString stringWithFormat:@"About %@", self.name];
    self.aboutMeLabel.textAlignment = NSTextAlignmentCenter;
    self.aboutMeLabel.textColor = [UIColor whiteColor];
    [self.aboutMeLabel setFont:[UIFont systemFontOfSize:16.0]];
    [self.scrollView addSubview:self.aboutMeLabel];
    self.verticalOffset = self.verticalOffset + self.aboutMeLabel.frame.size.height;

    //Add bio textView
    self.bioTextView = [[UITextView alloc] init];
    self.bioTextView.frame = CGRectMake((self.scrollView.frame.size.width /2) - 140, self.verticalOffset, 280, 70);
    self.bioTextView.text = self.bioText;
    self.bioTextView.editable = NO;
    self.bioTextView.textAlignment = NSTextAlignmentCenter;
    self.bioTextView.textColor = [UIColor whiteColor];
    self.bioTextView.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:self.bioTextView];
    self.verticalOffset = self.verticalOffset + self.bioTextView.frame.size.height + 10;

    //Add interested label
    self.interestedLabel = [[UILabel alloc] init];
    self.interestedLabel.frame = CGRectMake((self.scrollView.frame.size.width /2) - 140, self.verticalOffset, 280, 30);
    self.interestedLabel.text = self.sexualOrientation;
    self.interestedLabel.textAlignment = NSTextAlignmentCenter;
    self.interestedLabel.textColor = [UIColor whiteColor];
    [self.interestedLabel setFont:[UIFont systemFontOfSize:16.0]];
    [self.scrollView addSubview:self.interestedLabel];
    self.verticalOffset = self.verticalOffset + self.interestedLabel.frame.size.height + 10;

    //Add Favorite drink label
    self.favDrinkLabel = [[UILabel alloc] init];
    self.favDrinkLabel.frame = CGRectMake((self.scrollView.frame.size.width /2) - 140, self.verticalOffset, 280, 30);
    self.favDrinkLabel.text = [NSString stringWithFormat:@"Favorite drink: %@", self.favDrink];
    self.favDrinkLabel.textAlignment = NSTextAlignmentCenter;
    self.favDrinkLabel.textColor = [UIColor whiteColor];
    [self.favDrinkLabel setFont:[UIFont systemFontOfSize:16.0]];
    [self.scrollView addSubview:self.favDrinkLabel];
    self.verticalOffset = self.verticalOffset + self.favDrinkLabel.frame.size.height + 15;

    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.verticalOffset);
    self.scrollView.contentMode = UIViewContentModeScaleAspectFit;

    self.activityIndicator.hidden = YES;
    [self.activityIndicator stopAnimating];
    
    [self setStyle];
}

-(void)getPersonalData
{

    //Get name text.
    self.name = [self.user objectForKey:@"name"];

    //Get bio text.
    if ([self.user objectForKey:@"bio"]) {

        self.bioText = [self.user objectForKey:@"bio"];
    }
    else
    {
        self.bioText = @"";
    }

    //Get favorite drink.
    if ([self.user objectForKey:@"favoriteDrink"])
    {
        self.favDrink = [self.user objectForKey:@"favoriteDrink"];
    }

    //Get gender.
    if ([[self.user objectForKey:@"gender"] isEqual:@0])
    {
        self.gender = @"Female";
    }
    else if ([[self.user objectForKey:@"gender"] isEqual:@1])
    {
        self.gender = @"Male";
    }
    else if ([[self.user objectForKey:@"gender"] isEqual:@2])
    {
        self.gender = @"Other";
    }

    //Get age.
    if ([self.user objectForKey:@"age"])
    {
        NSNumber *age = [self.user objectForKey:@"age"];
        self.age = [NSString stringWithFormat:@"%@", age];
        NSLog(@"%@", self.age);
        NSLog(@"%@", [self.age class]);
    }
    else
    {
        self.age = @"";
        NSLog(@"%@", self.age);
        NSLog(@"%@", [self.age class]);
    }

    //Get sexual orientation.
    if ([[self.user objectForKey:@"sexualOrientation"] isEqual:@0])
    {
        self.sexualOrientation = @"Interested in: Men";
    }
    else if ([[self.user objectForKey:@"sexualOrientation"] isEqual:@1])
    {
        self.sexualOrientation = @"Interested in: Women";
    }
    else if ([[self.user objectForKey:@"sexualOrientation"] isEqual:@2])
    {
        self.sexualOrientation = @"Bisexual";
    }
    else
    {
        self.sexualOrientation = @"";
    }

    self.imagesArray = [NSMutableArray new];

    if ([self.user objectForKey:@"picture"] != nil) {
        PFFile *file = [self.user objectForKey:@"picture"];
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
    NSArray *tempArray = [self.user objectForKey:@"imagesArray"];

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

#pragma mark - Alert Showing Invitation to join Session

-(void)receivedInvitationForConnection:(NSNotification *)notification
{
    MCPeerID *peerID = [[notification userInfo]objectForKey:@"peerID"];
    NSString *alertViewString = [NSString stringWithFormat:@"%@ wants to connect and chat with you", peerID.displayName];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:alertViewString message:nil delegate:self cancelButtonTitle:@"Decline" otherButtonTitles:@"Accept", nil];
    [alertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    BOOL accept = (buttonIndex != alertView.cancelButtonIndex);

    void (^invitationHandler)(BOOL, MCSession *) = [self.appDelegate.mcManager.invitationHandlerArray objectAtIndex:0];
    invitationHandler(accept, self.appDelegate.mcManager.session);
}

- (IBAction)onButtonPressedDismissVC:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Styling method
-(void)setStyle
{
    self.view.backgroundColor = [UIColor blackColor];
    [self.backButtonOutlet setTitleColor:[UIColor buttonColor] forState:UIControlStateSelected];
    [self.backButtonOutlet setTitleColor:[UIColor buttonColor] forState:UIControlStateNormal];
    [self.backButtonOutlet setTitleColor:[UIColor buttonColor] forState:UIControlStateHighlighted];
    self.fakeNavBar.backgroundColor = [UIColor clearColor];
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
    [self.largeImageView removeFromSuperview];

    [self addViewsToScrollView];
}

-(void)dismissLargePics:(id)sender
{

    NSLog(@"I ran");
    self.pictureButtonPressed = NO;

    [self.nameageLabel removeFromSuperview];
    [self.genderLabel removeFromSuperview];
    [self.interestedLabel removeFromSuperview];
    [self.favDrinkLabel removeFromSuperview];
    [self.aboutMeLabel removeFromSuperview];
    [self.bioTextView removeFromSuperview];
    [self.profileImageView removeFromSuperview];
    [self.largeImageView removeFromSuperview];

    [self addViewsToScrollView];
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)swipe {

    if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
        NSLog(@"Left Swipe");
        if (self.swipeIndex == self.imagesArray.count -1) {
            NSLog(@"Swipe Index = %ld", (long)self.swipeIndex);
        }
        else {
            self.swipeIndex += 1;
            self.largeImageView.image = [self.imagesArray objectAtIndex:self.swipeIndex];
            self.pageControl.currentPage = self.swipeIndex;
            NSLog(@"Swipe Index = %ld", (long)self.swipeIndex);
        }
    }

    if (swipe.direction == UISwipeGestureRecognizerDirectionRight) {
        NSLog(@"Right Swipe");
        if (self.swipeIndex == 0) {
            NSLog(@"Swipe Index = %ld", (long)self.swipeIndex);
        }
        else {
            self.swipeIndex -= 1;
            self.largeImageView.image = [self.imagesArray objectAtIndex:self.swipeIndex];
            self.pageControl.currentPage = self.swipeIndex;
            NSLog(@"Swipe Index = %ld", (long)self.swipeIndex);
        }
    }
}


@end
