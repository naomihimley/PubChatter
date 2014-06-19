//
//  ProfileViewController.m
//  PubChatter
//
//  Created by David Warner on 6/13/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()<CLLocationManagerDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *genderLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UITextView *bioTextView;
@property (weak, nonatomic) IBOutlet UILabel *sexualOrientationLabel;
@property (weak, nonatomic) IBOutlet UILabel *favDrinkLabel;

@property (strong, nonatomic) CLBeaconRegion *richRegion;
@property (strong, nonatomic) CLBeaconRegion *estimoteRegion;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property BOOL inARegion;
@end

@implementation ProfileViewController
//pauses location
//check if did
- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusAvailable) {

        NSLog(@"Background updates are available for the app.");
    }else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied)
    {
        NSLog(@"The user explicitly disabled background behavior for this app or for the whole system.");
    }else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted)
    {
        NSLog(@"Background updates are unavailable and the user cannot enable them again. For example, this status can occur when parental controls are in effect for the current user.");
    }

    if (![CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]])
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Unable To Monitor Location" message:@"Only works on iOS 5 and later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    self.navigationItem.title= @"PubChatter";
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
    [self setTextFields];
    if ([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        if ([PFUser currentUser])
        {
            [self createBeaconRegion];
            [self.locationManager startUpdatingLocation];
            [self.locationManager requestStateForRegion:self.richRegion];
            [self.locationManager requestStateForRegion:self.estimoteRegion];
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
    if ([[PFUser currentUser]objectForKey:@"age"]) {
        NSNumber *ageNumber = [[PFUser currentUser]objectForKey:@"age"];
        self.ageLabel.text = [NSString stringWithFormat:@"%@", ageNumber];
    }
    else
    {
        self.ageLabel.text = @"";
    }
    if ([[PFUser currentUser]objectForKey:@"bio"]) {
        self.bioTextView.text = [[PFUser currentUser]objectForKey:@"bio"];
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

- (void)createBeaconRegion
{
    //all estimote iBeacons
    NSUUID *estimoteUUID = [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
    self.estimoteRegion = [[CLBeaconRegion alloc]initWithProximityUUID:estimoteUUID identifier:@"anyEstimoteBeacon"];
    self.estimoteRegion.notifyOnEntry = YES;
    self.estimoteRegion.notifyOnExit = YES;
    self.estimoteRegion.notifyEntryStateOnDisplay = YES;
    [self.locationManager startMonitoringForRegion:self.estimoteRegion];

    //rich's phone
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"8492E75F-4FD6-469D-B132-043FE94921D8"];
    self.richRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"richiPhone"];
    self.richRegion.notifyOnEntry = YES;
    self.richRegion.notifyOnExit=YES;
    self.richRegion.notifyEntryStateOnDisplay=YES;
    [self.locationManager startMonitoringForRegion:self.richRegion];
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
    if ([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]])
    {
        [self.locationManager stopMonitoringForRegion:self.richRegion];
        [self.locationManager stopMonitoringForRegion:self.estimoteRegion];
        [self.locationManager stopRangingBeaconsInRegion:self.richRegion];
        [self.locationManager stopRangingBeaconsInRegion:self.estimoteRegion];
    }
}
#pragma mark - CLLocationManagerDelegate Methods

-(void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    if (state == CLRegionStateInside)
    {
        //this method is for when the user opens the app already inside of a region. DidEnterRegion will not get called because they wont cross the boundary, but this checks the CLRegionState and changes our bool.
        [manager startRangingBeaconsInRegion:self.richRegion];
        [manager startRangingBeaconsInRegion:self.estimoteRegion];
        self.inARegion = YES;
    }
    else if (state == CLRegionStateOutside)
    {
        if ([region.identifier isEqualToString:@"richiPhone"])
        {
            PFQuery *queryForBar = [PFQuery queryWithClassName:@"Bar"];
            [queryForBar whereKey:@"objectId" equalTo:@"UL0yMO2bGj"];
            [queryForBar findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                PFObject *bar = [objects firstObject];
                [bar removeObject:[PFUser currentUser] forKey:@"usersInBar"];
                [bar saveInBackground];
            }];
        }
        if ([region.identifier isEqualToString:@"anyEstimoteBeacon"])
        {
            PFQuery *queryForBar = [PFQuery queryWithClassName:@"Bar"];
            [queryForBar whereKey:@"objectId" equalTo:@"UL0yMO2bGj"];
            [queryForBar findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                PFObject *bar = [objects firstObject];
                [bar removeObject:[PFUser currentUser] forKey:@"usersInBar"];
                [bar saveInBackground];
            }];

        }
        //checks parse to see what bar the user was in and removes them.

        self.inARegion = NO;
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
        if ([beacon.minor isEqual: @2] && [beacon.major isEqual:@40358]) //old town ale house
        {
            PFQuery *queryForBar = [PFQuery queryWithClassName:@"Bar"];
            [queryForBar whereKey:@"objectId" equalTo:@"cxmc5pwBsf"];
            [queryForBar includeKey:@"usersInBar"];
            [queryForBar findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                PFObject *bar = [objects firstObject];
                NSArray *arrayOfUsers = [NSArray arrayWithArray:[bar objectForKey:@"usersInBar"]];
                if (arrayOfUsers.count < 1) {
                    [bar addObject:[PFUser currentUser] forKey:@"usersInBar"];
                    [bar saveInBackground];
                    self.inARegion = NO;
                }
                NSEnumerator *enumerator = [arrayOfUsers objectEnumerator];
                PFUser* user;
                while (user = [enumerator nextObject]) {
                    if (![[user objectForKey:@"username"]isEqual:[[PFUser currentUser]objectForKey:@"username"]]) {
                        [bar addObject:[PFUser currentUser] forKey:@"usersInBar"];
                        [bar saveInBackground];
                        self.inARegion = NO;
                    }
                }
                self.inARegion = NO;
                self.navigationItem.title = [bar objectForKey:@"barName"];
            }];
        }
        else if ([beacon.minor isEqual: @23023] && [beacon.major isEqual: @4921]) //rich's iPhone MM
        {
            PFQuery *queryForBar = [PFQuery queryWithClassName:@"Bar"];
            [queryForBar whereKey:@"objectId" equalTo:@"UL0yMO2bGj"];
            [queryForBar findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                PFObject *bar = [objects firstObject];
                NSArray *arrayOfUsers = [NSArray arrayWithArray:[bar objectForKey:@"usersInBar"]];
                if (![arrayOfUsers containsObject:[[PFUser currentUser] objectId]]) {
                    [bar addObject:[PFUser currentUser] forKey:@"usersInBar"];
                    [bar saveInBackground];
                    NSLog(@"addingObject to rich's iphone");
                    self.inARegion = NO;
                }
                self.inARegion = NO;
                self.navigationItem.title = [bar objectForKey:@"barName"];
            }];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    if ([region.identifier isEqualToString:@"anyEstimoteBeacon"])
    {
        [self.locationManager startRangingBeaconsInRegion:self.estimoteRegion];
    }
    if ([region.identifier isEqualToString:@"richiPhone"])
    {
        [self.locationManager startRangingBeaconsInRegion:self.richRegion];
    }
    self.inARegion = YES;
    NSLog(@"did enter");
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"did exit");
    [self.locationManager stopRangingBeaconsInRegion:self.richRegion];
    [self.locationManager stopMonitoringForRegion:self.estimoteRegion];
    self.inARegion = NO;
    PFQuery *queryForBar = [PFQuery queryWithClassName:@"Bar"];
    [queryForBar whereKey:@"usersInBar" equalTo:[PFUser currentUser]];
    [queryForBar findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        PFObject *bar = [objects firstObject];
        //remove the repeated line once the user stops being put in the parse array twice
        [bar removeObject:[PFUser currentUser] forKey:@"usersInBar"];
        [bar removeObject:[PFUser currentUser] forKey:@"usersInBar"];
        [bar saveInBackground];
    }];
    self.navigationItem.title= @"PubChatter";
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
