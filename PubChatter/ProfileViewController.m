//
//  ProfileViewController.m
//  PubChatter
//
//  Created by David Warner on 6/13/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import "ProfileViewController.h"
#import "AppDelegate.h"

@interface ProfileViewController ()<CLLocationManagerDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *genderLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UITextView *bioTextView;
@property (weak, nonatomic) IBOutlet UILabel *sexualOrientationLabel;
@property (weak, nonatomic) IBOutlet UILabel *favDrinkLabel;
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
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
     {
         self.profileImageView.image = [UIImage imageWithData:data];
     }];
    self.nameLabel.text = [[[PFUser currentUser]objectForKey:@"username"] uppercaseString];
    if ([[PFUser currentUser]objectForKey:@"age"]) {
        self.ageLabel.text = [NSString stringWithFormat:@"%@", [[PFUser currentUser]objectForKey:@"age"]];
    }
    else
    {
        self.ageLabel.text = @"";
    }
    if ([[PFUser currentUser]objectForKey:@"bio"]) {
        self.bioTextView.text = [[PFUser currentUser]objectForKey:@"bio"];
    }
    else
    {
        self.bioTextView.text = @"";
    }
    if ([[PFUser currentUser]objectForKey:@"favoriteDrink"]) {
        self.favDrinkLabel.text = [[PFUser currentUser]objectForKey:@"favoriteDrink"];
        [self.favDrinkLabel sizeToFit];
    }
     if ([[[PFUser currentUser]objectForKey:@"gender"] isEqual:@0])
     {
         self.genderLabel.text = @"F";
     }
     else if ([[[PFUser currentUser]objectForKey:@"gender"] isEqual:@1])
     {
         self.genderLabel.text = @"M";
     }
     else if ([[[PFUser currentUser]objectForKey:@"gender"] isEqual:@2])
     {
         self.genderLabel.text = @"Other";
         [self.genderLabel sizeToFit];
     }
     else
     {
         self.genderLabel.text = @"";
     }
     if ([[[PFUser currentUser]objectForKey:@"sexualOrientation"] isEqual:@0])
     {
         self.sexualOrientationLabel.text = @"Interested in Men";
         [self.sexualOrientationLabel sizeToFit];
     }
     else if ([[[PFUser currentUser]objectForKey:@"sexualOrientation"] isEqual:@1])
     {
         self.sexualOrientationLabel.text = @"Interested in Women";
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



@end
