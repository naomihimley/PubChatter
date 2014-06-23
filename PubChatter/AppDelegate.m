//
//  AppDelegate.m
//  PubChatter
//
//  Created by Yeah Right on 6/13/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "Rating.h"
#import "Bar.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Parse setApplicationId:@"B8JvVtX5W4w0OwlMSLzLQZBvW3j8xbHQ7bElMK47"
                  clientKey:@"v9ld8HOcNGdn3xIzeFZ9WS9KofND8Y4rsEzH6mwU"];

    self.mcManager = [[MCManager alloc]init];
    self.beaconRegionManager = [[BeaconRegionManager alloc]init];
    [Rating registerSubclass];
    [Bar registerSubclass];

    //should this be here?
    if (![CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]])
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Unable To Monitor Location" message:@"Only works on iOS 5 and later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    return YES;

}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    PFQuery *queryForBar = [PFQuery queryWithClassName:@"Bar"];
    [queryForBar findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (PFObject *bar in objects) {
            [bar removeObject:[PFUser currentUser] forKey:@"usersInBar"];
            [bar saveInBackground];
        }
    }];

}

@end
