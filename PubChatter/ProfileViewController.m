//
//  ProfileViewController.m
//  PubChatter
//
//  Created by David Warner on 6/13/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()<CLLocationManagerDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>
@property BOOL inARegion;
@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) CLLocationManager *locationManager;
@end

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (![PFUser currentUser])
    {
        PFLogInViewController *loginViewController = [PFLogInViewController new];
        PFSignUpViewController *signupViewController = [PFSignUpViewController new];
        loginViewController.delegate = self;
        signupViewController.delegate = self;
        loginViewController.signUpController = signupViewController;
        [self presentViewController:loginViewController animated:YES completion:nil];
    }
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self createBeaconRegion];
    self.inARegion = NO;
    //possibly making the app keep updating in the background?
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
    [self.locationManager startUpdatingLocation];
}

//automatically dismisses LogInVC when user hits enter or ok
- (void)logInViewController:(PFLogInViewController *)controller
               didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)createBeaconRegion
{
    //all estimote iBeacons
//    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];

    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"8492E75F-4FD6-469D-B132-043FE94921D8"]; //rich's phone
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"irrelevant identifier"];
    //possibly will refresh the app in background?
    self.beaconRegion.notifyOnEntry = YES;
    self.beaconRegion.notifyOnExit=YES;
    self.beaconRegion.notifyEntryStateOnDisplay=YES;
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
}

#pragma mark - CLLocationManagerDelegate Methods

- (void) locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    [self.locationManager requestStateForRegion:self.beaconRegion];
}

-(void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    if (state == CLRegionStateInside)
    {
        //this method is good for if the user opens the app already inside of a region. DidEnterRegion will not get called because they wont cross the boundary, but this checks the CLRegionState and changes our bool.
        [manager startRangingBeaconsInRegion:self.beaconRegion];
        NSLog(@"CLRegionStateInside");
        self.inARegion = YES;
    }
    else
    {
        [manager stopRangingBeaconsInRegion:self.beaconRegion];
    }
}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
    NSLog(@"ranging failed : %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    CLBeacon *beacon = [[CLBeacon alloc]init];
    //this code is for only looking for a single beacon. That is why we are calling lastObject on the beacons array. Otherwise you'd want to query all beacons and figure out which you are in proximity to.
    beacon = [beacons lastObject];
    if (self.inARegion == YES)
    {
        if ([beacon.minor  isEqual: @2])
        {
            PFQuery *queryForBar = [PFQuery queryWithClassName:@"Bar"];
            [queryForBar whereKey:@"objectId" equalTo:@"cxmc5pwBsf"];
            [queryForBar findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                PFObject *bar = [objects firstObject];
                [bar addObject:[PFUser currentUser] forKey:@"usersInBar"];
                [bar saveInBackground];
                self.inARegion = NO;
            }];
        }
        else if ([beacon.minor isEqual: @23023]) //rich's iPhone
        {
            PFQuery *queryForBar = [PFQuery queryWithClassName:@"Bar"];
            [queryForBar whereKey:@"objectId" equalTo:@"UL0yMO2bGj"];
            [queryForBar findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                PFObject *bar = [objects firstObject];
                [bar addObject:[PFUser currentUser] forKey:@"usersInBar"];
                [bar saveInBackground];
                self.inARegion = NO;
            }];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    self.inARegion = YES;
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    self.inARegion = NO;
    PFQuery *queryForBar = [PFQuery queryWithClassName:@"Bar"];
    [queryForBar whereKey:@"usersInBar" equalTo:[PFUser currentUser]];
    [queryForBar findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        PFObject *bar = [objects firstObject];
        [bar removeObject:[PFUser currentUser] forKey:@"usersInBar"];
        [bar saveInBackground];
    }];
}









@end
