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
    //all estimote iBeacons
    NSUUID *estimoteUUID = [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
    self.estimoteRegion = [[CLBeaconRegion alloc]initWithProximityUUID:estimoteUUID identifier:@"anyEstimoteBeacon"];
    self.estimoteRegion.notifyOnEntry = YES;
    self.estimoteRegion.notifyOnExit = YES;
    self.estimoteRegion.notifyEntryStateOnDisplay = YES;
    [self.beaconRegionManager startMonitoringForRegion:self.estimoteRegion];

    //rich's phone
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"8492E75F-4FD6-469D-B132-043FE94921D8"];
    self.richRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"richiPhone"];
    self.richRegion.notifyOnEntry = YES;
    self.richRegion.notifyOnExit=YES;
    self.richRegion.notifyEntryStateOnDisplay=YES;
    [self.beaconRegionManager startMonitoringForRegion:self.richRegion];
    [self.beaconRegionManager requestStateForRegion:self.estimoteRegion];
}

- (void)logout
{
    [self.beaconRegionManager stopMonitoringForRegion:self.richRegion];
    [self.beaconRegionManager stopMonitoringForRegion:self.estimoteRegion];
    [self.beaconRegionManager stopRangingBeaconsInRegion:self.richRegion];
    [self.beaconRegionManager stopRangingBeaconsInRegion:self.estimoteRegion];
}

#pragma mark - CLLocationManagerDelegate Methods

//this delegate method gets called whenever didEnterRegion, didExitRegion, requestStateForRegion, and whenever the user wakes up their device from sleep, Even with the app in background because notifyEntryStateOnDisplay is set to YES

-(void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    if (state == CLRegionStateInside)
    {
        self.inARegion = YES;
        [manager startRangingBeaconsInRegion:self.richRegion];
        [manager startRangingBeaconsInRegion:self.estimoteRegion];
//        [self.appDelegate.mcManager advertiseSelf:YES];

    }
    else if (state == CLRegionStateOutside)
    {
//        [self.appDelegate.mcManager advertiseSelf:NO];
        if ([region.identifier isEqualToString:@"richiPhone"])
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"userEnteredBar" object:nil userInfo:@{@"barName": @"PubChat"}];
            if ([PFUser currentUser]) {
                PFQuery *queryForBar = [PFQuery queryWithClassName:@"Bar"];
                [queryForBar whereKey:@"objectId" equalTo:@"UL0yMO2bGj"];
                [queryForBar findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    PFObject *bar = [objects firstObject];
                    [bar removeObject:[PFUser currentUser] forKey:@"usersInBar"];
                    [bar saveInBackground];
                }];
            }
        }
        if ([region.identifier isEqualToString:@"anyEstimoteBeacon"])
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
        if ([beacon.minor isEqual: @52834] && [beacon.major isEqual:@12505]) //old town ale house
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"userEnteredBar" object:nil userInfo:@{@"barName": @"Old Town Ale House"}];
            PFQuery *queryForBar = [PFQuery queryWithClassName:@"Bar"];
            [queryForBar whereKey:@"objectId" equalTo:@"cxmc5pwBsf"];
            [queryForBar includeKey:@"usersInBar"];
            [queryForBar findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                PFObject *bar = [objects firstObject];
                NSArray *arrayOfUsers = [NSArray arrayWithArray:[bar objectForKey:@"usersInBar"]];
                if (arrayOfUsers.count <= 0) {
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
            }];
        }
        else if ([beacon.minor isEqual: @23023] && [beacon.major isEqual: @4921]) //rich's iPhone MM
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"userEnteredBar" object:nil userInfo:@{@"barName": @"Rich's iPhone"}];
            PFQuery *queryForBar = [PFQuery queryWithClassName:@"Bar"];
            [queryForBar whereKey:@"objectId" equalTo:@"UL0yMO2bGj"];
            [queryForBar findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                PFObject *bar = [objects firstObject];
                NSArray *arrayOfUsers = [NSArray arrayWithArray:[bar objectForKey:@"usersInBar"]];
                if (![arrayOfUsers containsObject:[[PFUser currentUser] objectId]]) {
                    [bar addObject:[PFUser currentUser] forKey:@"usersInBar"];
                    [bar saveInBackground];
                    self.inARegion = NO;
                }
                self.inARegion = NO;
            }];
        }
        else if ([beacon.minor isEqual: @6704] && [beacon.major isEqual: @19218]) //Green Door
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"userEnteredBar" object:nil userInfo:@{@"barName": @"Green Door"}];
            PFQuery *queryForBar = [PFQuery queryWithClassName:@"Bar"];
            [queryForBar whereKey:@"objectId" equalTo:@"CnWKUJftyT"];
            [queryForBar findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                PFObject *bar = [objects firstObject];
                NSArray *arrayOfUsers = [NSArray arrayWithArray:[bar objectForKey:@"usersInBar"]];
                if (![arrayOfUsers containsObject:[[PFUser currentUser] objectId]]) {
                    [bar addObject:[PFUser currentUser] forKey:@"usersInBar"];
                    [bar saveInBackground];
                    self.inARegion = NO;
                }
                self.inARegion = NO;
            }];
        }
        else if ([beacon.minor isEqual: @16063] && [beacon.major isEqual: @13963]) //Municipal Bar
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"userEnteredBar" object:nil userInfo:@{@"barName": @"Municipal Bar"}];
            PFQuery *queryForBar = [PFQuery queryWithClassName:@"Bar"];
            [queryForBar whereKey:@"objectId" equalTo:@"qVTGKr4142"];
            [queryForBar findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                PFObject *bar = [objects firstObject];
                NSArray *arrayOfUsers = [NSArray arrayWithArray:[bar objectForKey:@"usersInBar"]];
                if (![arrayOfUsers containsObject:[[PFUser currentUser] objectId]]) {
                    [bar addObject:[PFUser currentUser] forKey:@"usersInBar"];
                    [bar saveInBackground];
                    self.inARegion = NO;
                }
                self.inARegion = NO;
            }];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    if ([region.identifier isEqualToString:@"anyEstimoteBeacon"])
    {
        [self.beaconRegionManager startRangingBeaconsInRegion:self.estimoteRegion];
    }
    if ([region.identifier isEqualToString:@"richiPhone"])
    {
        [self.beaconRegionManager startRangingBeaconsInRegion:self.richRegion];
    }
    self.inARegion = YES;
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    if ([region.identifier isEqualToString:@"anyEstimoteBeacon"])
    {
        //removes User from all bar
        [[NSNotificationCenter defaultCenter]postNotificationName:@"userEnteredBar" object:nil userInfo:@{@"barName": @"PubChat"}];
        self.inARegion = NO;
        PFQuery *queryForBar = [PFQuery queryWithClassName:@"Bar"];
        [queryForBar whereKey:@"objectId" equalTo:@"cxmc5pwBsf"];
        [queryForBar findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            for (PFObject *bar in objects) {
                [bar removeObject:[PFUser currentUser] forKey:@"usersInBar"];
                [bar saveInBackground];
            }
        }];
    }
    if ([region.identifier isEqualToString:@"richiPhone"])
    {
        self.inARegion = NO;
        PFQuery *queryForBar = [PFQuery queryWithClassName:@"Bar"];
        [queryForBar whereKey:@"objectId" equalTo:@"UL0yMO2bGj"];
        [queryForBar findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            PFObject *bar = [objects firstObject];
            [bar removeObject:[PFUser currentUser] forKey:@"usersInBar"];
            [bar saveInBackground];
        }];
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self.beaconRegionManager stopUpdatingLocation];
}


@end