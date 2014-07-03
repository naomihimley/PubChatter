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

@property (strong, nonatomic) UITextView *bioTextView;
@property (strong, nonatomic) UILabel *nameageLabel;
@property (strong, nonatomic) UILabel *genderLabel;
@property (strong, nonatomic) UILabel *ageLabel;
@property (strong, nonatomic) UILabel *interestedLabel;
@property (strong, nonatomic) UILabel *favDrinkLabel;
@property (strong, nonatomic) UILabel *aboutMeLabel;
@property (weak, nonatomic) IBOutlet UIView *fakeNavBar;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property AppDelegate *appDelegate;
@property (weak, nonatomic) IBOutlet UIButton *backButtonOutlet;
-(void)receivedInvitationForConnection: (NSNotification *)notification;

@end

@implementation OPPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.chatArray = [NSMutableArray array];
    self.chatDictionaryArray = [NSMutableArray array];
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receivedInvitationForConnection:) name:@"MCReceivedInvitation" object:nil];
    self.scrollView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.bioTextView removeFromSuperview];
    [self.nameageLabel removeFromSuperview];
    [self.genderLabel removeFromSuperview];
    [self.interestedLabel removeFromSuperview];
    [self.favDrinkLabel removeFromSuperview];
    [self.aboutMeLabel removeFromSuperview];
    [self getPersonalData];
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
    self.aboutMeLabel.textColor = [UIColor whiteColor];
    [self.aboutMeLabel setFont:[UIFont systemFontOfSize:16.0]];
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
    [self.interestedLabel setFont:[UIFont systemFontOfSize:16.0]];
    [self.scrollView addSubview:self.interestedLabel];
    verticalOffset = verticalOffset + self.interestedLabel.frame.size.height + 10;

    //Add Favorite drink label
    self.favDrinkLabel = [[UILabel alloc] init];
    self.favDrinkLabel.frame = CGRectMake((self.scrollView.frame.size.width /2) - 140, verticalOffset, 280, 30);
    self.favDrinkLabel.text = [NSString stringWithFormat:@"Favorite drink: %@", self.favDrink];
    self.favDrinkLabel.textAlignment = NSTextAlignmentCenter;
    self.favDrinkLabel.textColor = [UIColor whiteColor];
    [self.favDrinkLabel setFont:[UIFont systemFontOfSize:16.0]];
    [self.scrollView addSubview:self.favDrinkLabel];
    verticalOffset = verticalOffset + self.favDrinkLabel.frame.size.height + 15;

    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, verticalOffset);
    self.scrollView.contentMode = UIViewContentModeScaleAspectFit;

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

    //Get user image.
    PFFile *file = [self.user objectForKey:@"picture"];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
     {
         self.profileImage = [UIImage imageWithData:data];
         [self addViewsToScrollView];
     }];
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
    [self.backButtonOutlet setTitleColor:[UIColor buttonColor] forState:UIControlStateSelected];
    [self.backButtonOutlet setTitleColor:[UIColor buttonColor] forState:UIControlStateNormal];
    [self.backButtonOutlet setTitleColor:[UIColor buttonColor] forState:UIControlStateHighlighted];
    self.fakeNavBar.backgroundColor = [UIColor clearColor];

}


@end
