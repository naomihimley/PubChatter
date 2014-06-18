//
//  ProfileViewController.m
//  PubChatter
//
//  Created by David Warner on 6/13/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()<CLLocationManagerDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *barNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *genderLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UITextView *bioTextView;
@property (weak, nonatomic) IBOutlet UILabel *sexualOrientationLabel;
@property (weak, nonatomic) IBOutlet UILabel *favDrinkLabel;

@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) CLBeaconRegion *estimoteRegion;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property BOOL inARegion;
@end

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (![CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]])
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Unable To Monitor Location" message:@"Only works on iOS 5 and later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (![PFUser currentUser])
    {
        PFLogInViewController *loginViewController = [PFLogInViewController new];
        PFSignUpViewController *signupViewController = [PFSignUpViewController new];
        loginViewController.delegate = self;
        signupViewController.delegate = self;
        loginViewController.signUpController = signupViewController;
        [self presentViewController:loginViewController animated:YES completion:nil];
    }
    self.inARegion = NO;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    //possibly making the app keep updating in the background?
    if ([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        if ([PFUser currentUser])
        {
            [self createBeaconRegion];
            [self.locationManager startUpdatingLocation];
            [self setTextFields];
        }
    }
}

- (void)setTextFields
{
    PFFile *file = [[PFUser currentUser]objectForKey:@"picture"];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
     {
         self.profileImageView.image = [UIImage imageWithData:data];
     }];

     self.nameLabel.text = [[[PFUser currentUser]objectForKey:@"username"] uppercaseString];
     self.ageLabel.text = [[PFUser currentUser]objectForKey:@"age"];
     self.bioTextView.text = [[PFUser currentUser]objectForKey:@"bio"];
     self.favDrinkLabel.text = [[PFUser currentUser]objectForKey:@"favoriteDrink"];
     [self.favDrinkLabel sizeToFit];
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

- (void)createBeaconRegion
{
    //all estimote iBeacons
    NSUUID *estimoteUUID = [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
    self.estimoteRegion = [[CLBeaconRegion alloc]initWithProximityUUID:estimoteUUID identifier:@"irrelevant"];
    self.estimoteRegion.notifyOnEntry = YES;
    self.estimoteRegion.notifyOnExit = YES;
    //location manager sends beacon notifications when the user turns on the display and the device is already inside the region. These notifications are sent even if your app is not running.
    self.estimoteRegion.notifyEntryStateOnDisplay = YES;
    [self.locationManager startMonitoringForRegion:self.estimoteRegion];

    //rich's phone
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"8492E75F-4FD6-469D-B132-043FE94921D8"];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"irrelevant identifier"];
    self.beaconRegion.notifyOnEntry = YES;
    self.beaconRegion.notifyOnExit=YES;
    self.beaconRegion.notifyEntryStateOnDisplay=YES;
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
}

#pragma mark - Parse Login Methods

- (void)logInViewController:(PFLogInViewController *)controller
               didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)onLogOutButtonTapped:(id)sender
{
    [PFUser logOut];
    [self.tabBarController setSelectedIndex:0];
    [self.locationManager stopMonitoringForRegion:self.beaconRegion];
    [self.locationManager stopMonitoringForRegion:self.estimoteRegion];
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    [self.locationManager stopRangingBeaconsInRegion:self.estimoteRegion];
}
#pragma mark - CLLocationManagerDelegate Methods

-(void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    if (state == CLRegionStateInside)
    {
        //this method is for when the user opens the app already inside of a region. DidEnterRegion will not get called because they wont cross the boundary, but this checks the CLRegionState and changes our bool.
        [manager startRangingBeaconsInRegion:self.beaconRegion];
        [manager startRangingBeaconsInRegion:self.estimoteRegion];
        NSLog(@"CLRegionStateInside");
        self.inARegion = YES;
    }
    else if (state == CLRegionStateOutside)
    {
        NSLog(@"CLRegionStateOutside");
        //checks parse to see what bar the user was in and removes them.
        PFQuery *queryForBar = [PFQuery queryWithClassName:@"Bar"];
        [queryForBar whereKey:@"usersInBar" equalTo:[PFUser currentUser]];
        [queryForBar findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            PFObject *bar = [objects firstObject];
            [bar removeObject:[PFUser currentUser] forKey:@"usersInBar"];
            [bar saveInBackground];
        }];
        self.inARegion = NO;
        self.navigationItem.title= @"PubChatter";
    }
}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
    NSLog(@"ranging failed : %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    //array is sorted by closest beacon to you
    CLBeacon *beacon = [[CLBeacon alloc]init];
    beacon = [beacons firstObject];
    if (self.inARegion == YES)
    {
        if ([beacon.minor isEqual: @2] && [beacon.major isEqual:@40358])
        {
            PFQuery *queryForBar = [PFQuery queryWithClassName:@"Bar"];
            [queryForBar whereKey:@"objectId" equalTo:@"cxmc5pwBsf"];
            [queryForBar findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                PFObject *bar = [objects firstObject];
                [bar addObject:[PFUser currentUser] forKey:@"usersInBar"];
                [bar saveInBackground];
                self.inARegion = NO;
                self.navigationItem.title = [bar objectForKey:@"barName"];
            }];
        }
        else if ([beacon.minor isEqual: @23023] && [beacon.major isEqual: @4921]) //rich's iPhone
        {
            NSLog(@"rich's iPhone");
            PFQuery *queryForBar = [PFQuery queryWithClassName:@"Bar"];
            [queryForBar whereKey:@"objectId" equalTo:@"UL0yMO2bGj"];
            [queryForBar findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                PFObject *bar = [objects firstObject];
                [bar addObject:[PFUser currentUser] forKey:@"usersInBar"];
                [bar saveInBackground];
                self.inARegion = NO;
                self.navigationItem.title = [bar objectForKey:@"barName"];
            }];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    [self.locationManager startRangingBeaconsInRegion:self.estimoteRegion];
    self.inARegion = YES;
    NSLog(@"did enter");
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"did exit");
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    [self.locationManager stopMonitoringForRegion:self.estimoteRegion];
    self.inARegion = NO;
    PFQuery *queryForBar = [PFQuery queryWithClassName:@"Bar"];
    [queryForBar whereKey:@"usersInBar" equalTo:[PFUser currentUser]];
    [queryForBar findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        PFObject *bar = [objects firstObject];
        [bar removeObject:[PFUser currentUser] forKey:@"usersInBar"];
        [bar saveInBackground];
    }];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self.locationManager stopUpdatingLocation];
}


#pragma mark - Segue Methods

- (IBAction)unwindSegueToProfileViewController:(UIStoryboardSegue *)sender
{

}





@end
