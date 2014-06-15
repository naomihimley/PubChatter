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
}

//automatically dismisses LogInVC when user hits enter or ok
- (void)logInViewController:(PFLogInViewController *)controller
               didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)createBeaconRegion
{
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"irrelevant identifier"];
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
    NSLog(@"createBeaconRegion was called");
}

#pragma mark - CLLocationManagerDelegate Methods
- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
    NSLog(@"ranging failed : %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    //this delegate method gets called every second while inside a region
    CLBeacon *beacon = [[CLBeacon alloc]init];
    //this code is for only looking for a single beacon. That is why we are calling lastObject on the beacons array. Otherwise you'd want to query all beacons and figure out which you are in proximity to.
    beacon = [beacons lastObject];
    if (self.inARegion == YES)
    {
        if ([beacon.minor  isEqual: @2])
        {
            //getting the correct bar for the beacon.
            PFQuery *queryForBar = [PFQuery queryWithClassName:@"Bar"];
            [queryForBar whereKey:@"objectId" equalTo:@"cxmc5pwBsf"];
            [queryForBar findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                PFObject *bar = [objects firstObject];
                //setting the usersInBar relation
                PFRelation *usersInBarRelation = [bar relationForKey:@"usersInBar"];
                [usersInBarRelation addObject:[PFUser currentUser]];
                [[PFUser currentUser]setObject:bar forKey:@"barUserIsIn"];
                //do I need to save the currentUser here?
                [[PFUser currentUser]saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    NSLog(@"saving the user");
                }];
                [bar saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    //save
                }];
                NSLog(@"%@", [bar objectForKey:@"barName"]);
                //because this method gets called every second, I set the bool to NO here to keep it from setting the relation every second.
                self.inARegion = NO;
            }];
        }
        else if ([beacon.minor isEqual: @1])
        {
            //depending on what we set the minor values to for the other beacons once we get them we will repeat the code from right above, setting the usersInBar relation.
        }

    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    self.inARegion = YES;
    NSLog(@"did enter");
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    self.inARegion = NO;
    NSLog(@"exited region");
}

@end
