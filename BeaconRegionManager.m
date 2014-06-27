//
//  BeaconRegionManager.m
//  PubChatter
//
//  Created by Yeah Right on 6/20/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import "BeaconRegionManager.h"
#import "AppDelegate.h"

@interface BeaconRegionManager () <CLLocationManagerDelegate>

@property AppDelegate *appDelegate;
@end

@implementation BeaconRegionManager
-(void)setupCLManager
{
    self.beaconRegionManager = [[CLLocationManager alloc] init];
    self.beaconRegionManager.delegate = self;
}

- (void)canUserUseApp
{
    if ([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusAvailable)
    {
        self.beaconRegionManager = [[CLLocationManager alloc] init];
        self.beaconRegionManager.delegate = self;
        [self.beaconRegionManager startUpdatingLocation];
        [self createBeaconRegion];
    }
    else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Turn on Background App Refresh to Use PubChat"
                                                       message:@"Go to Settings -> General -> Background App Refresh -> PubChatter"
                                                      delegate:nil
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
        [alert show];
    }else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted)
    {
        NSLog(@"Background updates are unavailable and the user cannot enable them again. For example, this status can occur when parental controls are in effect for the current user.");
    }

}

- (void)createBeaconRegion
{
    //Green Door
    NSUUID *estimoteUUIDGreenDoor = [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
    self.greenDoorRegion = [[CLBeaconRegion alloc]initWithProximityUUID:estimoteUUIDGreenDoor major:19218 minor:6704 identifier:@"Green Door"];
    self.greenDoorRegion.notifyOnEntry = YES;
    self.greenDoorRegion.notifyOnExit = YES;
    self.greenDoorRegion.notifyEntryStateOnDisplay = YES;
    [self.beaconRegionManager startMonitoringForRegion:self.greenDoorRegion];
    [self.beaconRegionManager startRangingBeaconsInRegion:self.greenDoorRegion];
    //Old Town Ale House
    NSUUID *estimoteUUIDOldTown = [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
    self.oldTownRegion = [[CLBeaconRegion alloc]initWithProximityUUID:estimoteUUIDOldTown major:19218 minor:52834 identifier:@"Old Town Ale House"];
    self.oldTownRegion.notifyOnEntry = YES;
    self.oldTownRegion.notifyOnExit = YES;
    self.oldTownRegion.notifyEntryStateOnDisplay = YES;
    [self.beaconRegionManager startMonitoringForRegion:self.oldTownRegion];
    [self.beaconRegionManager startRangingBeaconsInRegion:self.oldTownRegion];
    //Municipal Bar
    NSUUID *estimoteUUIDMunicipal = [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
    self.municipalRegion = [[CLBeaconRegion alloc]initWithProximityUUID:estimoteUUIDMunicipal major:19218 minor:16063 identifier:@"Municipal Bar"];
    self.municipalRegion.notifyOnEntry = YES;
    self.municipalRegion.notifyOnExit = YES;
    self.municipalRegion.notifyEntryStateOnDisplay = YES;
    [self.beaconRegionManager startMonitoringForRegion:self.municipalRegion];
    [self.beaconRegionManager startRangingBeaconsInRegion:self.municipalRegion];
}

- (void)logout
{
    [self.beaconRegionManager stopMonitoringForRegion:self.municipalRegion];
    [self.beaconRegionManager stopRangingBeaconsInRegion:self.municipalRegion];
    [self.beaconRegionManager stopMonitoringForRegion:self.greenDoorRegion];
    [self.beaconRegionManager stopRangingBeaconsInRegion:self.greenDoorRegion];
    [self.beaconRegionManager stopMonitoringForRegion:self.oldTownRegion];
    [self.beaconRegionManager stopRangingBeaconsInRegion:self.oldTownRegion];
}

#pragma mark - CLLocationManagerDelegate Methods

//this delegate method gets called whenever didEnterRegion, didExitRegion, requestStateForRegion, and whenever the user wakes up their device from sleep, Even with the app in background because notifyEntryStateOnDisplay is set to YES

-(void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    if ([PFUser currentUser])
    {
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    if (state == CLRegionStateInside)
    {
        self.firstRange = YES;
        [self.beaconRegionManager startMonitoringForRegion:self.greenDoorRegion];
        [self.beaconRegionManager startRangingBeaconsInRegion:self.greenDoorRegion];
        [self.beaconRegionManager startMonitoringForRegion:self.municipalRegion];
        [self.beaconRegionManager startRangingBeaconsInRegion:self.municipalRegion];
        [self.beaconRegionManager startMonitoringForRegion:self.oldTownRegion];
        [self.beaconRegionManager startRangingBeaconsInRegion:self.oldTownRegion];

    }
    else if (state == CLRegionStateOutside)
    {
//        [self.appDelegate.mcManager advertiseSelf:NO];
        if ([region.identifier isEqualToString:@"PubChat"])
        {
            //this removes user from all bars
            [[NSNotificationCenter defaultCenter]postNotificationName:@"userEnteredBar" object:nil userInfo:@{@"barName": @"PubChat"}];
            PFQuery *queryForBar = [PFQuery queryWithClassName:@"Bar"];
            [queryForBar findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                for (PFObject *bar in objects) {
                    [bar removeObject:[PFUser currentUser] forKey:@"usersInBar"];
                    [bar saveEventually];
                }

            }];

        }
        self.firstRange = NO;
    }
    }
}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
    NSLog(@"ranging failed : %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    if ([PFUser currentUser])
    {
    //array is sorted by closest beacon to you
    CLBeacon *beacon = [[CLBeacon alloc]init];
    beacon = [beacons firstObject];
    if (self.firstRange == YES)
    {
        if ([region.minor isEqual: @52834]) //old town ale house
        {
            self.firstRange = NO;
            [[NSNotificationCenter defaultCenter]postNotificationName:@"userEnteredBar" object:nil userInfo:@{@"barName": @"Old Town Ale House"}];
            PFQuery *queryForBar = [PFQuery queryWithClassName:@"Bar"];
            [queryForBar whereKey:@"objectId" equalTo:@"cxmc5pwBsf"];
            [queryForBar includeKey:@"usersInBar"];
            [queryForBar findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                PFObject *bar = [objects firstObject];
                NSArray *arrayOfUsers = [NSArray arrayWithArray:[bar objectForKey:@"usersInBar"]];
                if (arrayOfUsers.count <= 0)
                {
                    [bar addObject:[PFUser currentUser] forKey:@"usersInBar"];
                    [bar saveInBackground];
                    self.firstRange = NO;
                    NSLog(@"adding user to old town ale house");
                }
                else if (arrayOfUsers.count > 0)
                {
                    for (PFUser *userr in arrayOfUsers) {
                        if (![[userr objectForKey:@"username"]isEqual:[[PFUser currentUser]objectForKey:@"username"]]) {
                            [bar addObject:[PFUser currentUser] forKey:@"usersInBar"];
                            [bar saveInBackground];
                            self.firstRange = NO;
                        }
                    }
                }
                self.firstRange = NO;
            }];
        }
        else if ([region.minor isEqual: @6704]) //Green Door
        {
            self.firstRange = NO;
            [[NSNotificationCenter defaultCenter]postNotificationName:@"userEnteredBar" object:nil userInfo:@{@"barName": @"Green Door"}];
            PFQuery *queryForBar = [PFQuery queryWithClassName:@"Bar"];
            [queryForBar whereKey:@"objectId" equalTo:@"CnWKUJftyT"];
            [queryForBar includeKey:@"usersInBar"];
            [queryForBar findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                PFObject *bar = [objects firstObject];
                NSArray *arrayOfUsers = [NSArray arrayWithArray:[bar objectForKey:@"usersInBar"]];
                if (arrayOfUsers.count <= 0)
                {
                    [bar addObject:[PFUser currentUser] forKey:@"usersInBar"];
                    [bar saveInBackground];
                    self.firstRange = NO;
                    NSLog(@"adding user to green door");
                }
                else if (arrayOfUsers.count > 0)
                {
                    for (PFUser *user in arrayOfUsers) {
                        if (![[user objectForKey:@"username"]isEqual:[[PFUser currentUser]objectForKey:@"username"]]) {
                            [bar addObject:[PFUser currentUser] forKey:@"usersInBar"];
                            [bar saveInBackground];
                            self.firstRange = NO;
                        }
                    }
                }
                self.firstRange = NO;
            }];
        }
        else if ([region.minor isEqual: @16063]) //Municipal Bar
        {
            self.firstRange = NO;
            [[NSNotificationCenter defaultCenter]postNotificationName:@"userEnteredBar" object:nil userInfo:@{@"barName": @"Municipal Bar"}];
            PFQuery *queryForBar = [PFQuery queryWithClassName:@"Bar"];
            [queryForBar whereKey:@"objectId" equalTo:@"qVTGKr4142"];
            [queryForBar includeKey:@"usersInBar"];
            [queryForBar findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                PFObject *bar = [objects firstObject];
                NSArray *arrayOfUsers = [NSArray arrayWithArray:[bar objectForKey:@"usersInBar"]];
                if (arrayOfUsers.count <= 0)
                {
                    [bar addObject:[PFUser currentUser] forKey:@"usersInBar"];
                    [bar saveInBackground];
                    self.firstRange = NO;
                    NSLog(@"adding user to municipal bar");
                }
                else if (arrayOfUsers.count > 0)
                {
                    for (PFUser *user in arrayOfUsers) {
                        if (![[user objectForKey:@"username"]isEqual:[[PFUser currentUser]objectForKey:@"username"]]) {
                            [bar addObject:[PFUser currentUser] forKey:@"usersInBar"];
                            [bar saveInBackground];
                            self.firstRange = NO;
                        }
                    }
                }
                self.firstRange = NO;
            }];
        }
    }
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    if ([region.identifier isEqualToString:@"PubChat"])
    {
        [self.beaconRegionManager startMonitoringForRegion:self.greenDoorRegion];
        [self.beaconRegionManager startRangingBeaconsInRegion:self.greenDoorRegion];
        [self.beaconRegionManager startMonitoringForRegion:self.municipalRegion];
        [self.beaconRegionManager startRangingBeaconsInRegion:self.municipalRegion];
        [self.beaconRegionManager startMonitoringForRegion:self.oldTownRegion];
        [self.beaconRegionManager startRangingBeaconsInRegion:self.oldTownRegion];    }
    self.firstRange = YES;
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    if ([region.identifier isEqualToString:@"PubChat"])
    {
        //removes User from all bar
        [[NSNotificationCenter defaultCenter]postNotificationName:@"userEnteredBar" object:nil userInfo:@{@"barName": @"PubChat"}];
        self.firstRange = NO;
        PFQuery *queryForBar = [PFQuery queryWithClassName:@"Bar"];
        [queryForBar whereKey:@"objectId" equalTo:@"cxmc5pwBsf"];
        [queryForBar findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            for (PFObject *bar in objects) {
                [bar removeObject:[PFUser currentUser] forKey:@"usersInBar"];
                [bar saveInBackground];
            }
        }];
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self.beaconRegionManager stopUpdatingLocation];
}


@end