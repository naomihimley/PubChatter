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

@interface ProfileViewController ()<CLLocationManagerDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *genderLabel;
@property (weak, nonatomic) IBOutlet UITextView *bioTextView;
@property (weak, nonatomic) IBOutlet UILabel *sexualOrientationLabel;
@property (weak, nonatomic) IBOutlet UILabel *favDrinkLabel;
@property (weak, nonatomic) IBOutlet UIView *viewInBackground;
@property AppDelegate *appDelegate;

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
    self.navigationItem.title= @"PubChat";
    self.navigationController.navigationBar.backgroundColor = [UIColor navBarColor];
    self.viewInBackground.opaque = YES;
    self.viewInBackground.layer.opacity = 0.9f;
    self.viewInBackground.alpha = 0.9f;
    [self.viewInBackground setBackgroundColor:[[UIColor backgroundColor]colorWithAlphaComponent:0.9f]];

    self.view.backgroundColor = [UIColor blackColor];
    self.nameLabel.textColor = [UIColor nameColor];
    self.genderLabel.textColor = [UIColor whiteColor];
    self.bioTextView.editable = YES;
    self.bioTextView.textColor = [UIColor whiteColor];
    self.bioTextView.editable = NO;
    self.sexualOrientationLabel.textColor = [UIColor whiteColor];
    self.favDrinkLabel.textColor = [UIColor whiteColor];
    self.bioTextView.backgroundColor = [UIColor clearColor];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getParseData];
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

-(void)getParseData
{
    PFFile *file = [[PFUser currentUser]objectForKey:@"picture"];

    self.nameLabel.text = [[PFUser currentUser]objectForKey:@"name"];

    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
     {
         self.profileImageView.image = [UIImage imageWithData:data];
     }];

    if ([[PFUser currentUser]objectForKey:@"bio"]) {

        NSString *name = [[PFUser currentUser]objectForKey:@"name"];
        UIFont *boldFont = [UIFont boldSystemFontOfSize:12.0];
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"About %@\n%@", name, [[PFUser currentUser]objectForKey:@"bio"]]];
        [attrString addAttribute: NSFontAttributeName value: boldFont range: NSMakeRange(0, 6 + name.length)];
        self.bioTextView.attributedText = attrString;
    }
    else
    {
        self.bioTextView.text = @"No Bio Info";
    }

    if ([[PFUser currentUser]objectForKey:@"favoriteDrink"])
    {
        self.favDrinkLabel.text = [[PFUser currentUser]objectForKey:@"favoriteDrink"];
        [self.favDrinkLabel sizeToFit];
    }
     if ([[[PFUser currentUser]objectForKey:@"gender"] isEqual:@0] && [[PFUser currentUser]objectForKey:@"age"])
     {
         self.genderLabel.text = [NSString stringWithFormat:@"%@, female", [[PFUser currentUser]objectForKey:@"age"]];
         [self.genderLabel sizeToFit];
     }
     else if ([[[PFUser currentUser]objectForKey:@"gender"] isEqual:@1] && [[PFUser currentUser]objectForKey:@"age"])
     {
         self.genderLabel.text = [NSString stringWithFormat:@"%@, male", [[PFUser currentUser]objectForKey:@"age"]];
         [self.genderLabel sizeToFit];
     }
     else if ([[[PFUser currentUser]objectForKey:@"gender"] isEqual:@2] && [[PFUser currentUser]objectForKey:@"age"])
     {
         self.genderLabel.text = [NSString stringWithFormat:@"%@, other", [[PFUser currentUser]objectForKey:@"age"]];
         [self.genderLabel sizeToFit];
     }
     else if ([[[PFUser currentUser]objectForKey:@"gender"] isEqual:@0])
     {
         self.genderLabel.text = @"female";
         [self.genderLabel sizeToFit];
     }
     else if ([[[PFUser currentUser]objectForKey:@"gender"] isEqual:@1])
     {
         self.genderLabel.text = @"male";
         [self.genderLabel sizeToFit];
     }
     else if ([[[PFUser currentUser]objectForKey:@"gender"] isEqual:@2])
     {
         self.genderLabel.text = @"other";
         [self.genderLabel sizeToFit];
     }
    else if ([[PFUser currentUser]objectForKey:@"age"])
    {
        self.genderLabel.text = [NSString stringWithFormat:@"%@", [[PFUser currentUser]objectForKey:@"age"]];
    }
     else
     {
         self.genderLabel.text = @"No Info";
     }
     if ([[[PFUser currentUser]objectForKey:@"sexualOrientation"] isEqual:@0])
     {
         self.sexualOrientationLabel.text = @"Interested in: Men";
         [self.sexualOrientationLabel sizeToFit];
     }
     else if ([[[PFUser currentUser]objectForKey:@"sexualOrientation"] isEqual:@1])
     {
         self.sexualOrientationLabel.text = @"Interested in: Women";
         [self.sexualOrientationLabel sizeToFit];
     }
     else if ([[[PFUser currentUser]objectForKey:@"sexualOrientation"] isEqual:@2])
     {
         self.sexualOrientationLabel.text = @"Bisexual";
         [self.sexualOrientationLabel sizeToFit];
     }
     else
     {
         self.sexualOrientationLabel.text = @"";
     }
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

- (IBAction)onLogOutButtonTapped:(id)sender
{
    [PFUser logOut];
    [self.tabBarController setSelectedIndex:0];
}
@end
