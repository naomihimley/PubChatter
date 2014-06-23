//
//  BeaconRegionManager.h
//  PubChatter
//
//  Created by Yeah Right on 6/20/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <Parse/Parse.h>


@interface BeaconRegionManager : NSObject
@property (strong, nonatomic) CLBeaconRegion *richRegion;
@property (strong, nonatomic) CLBeaconRegion *estimoteRegion;
@property (strong, nonatomic) CLLocationManager *beaconRegionManager;
@property BOOL inARegion;
- (void)canUserUseApp;
- (void)setupCLManager;
- (void)createBeaconRegion;
- (void)logout;

@end
