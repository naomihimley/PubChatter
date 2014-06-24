//
//  AppDelegate.h
//  PubChatter
//
//  Created by Yeah Right on 6/13/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCManager.h"
#import "BeaconRegionManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property MCManager *mcManager;
@property BeaconRegionManager *beaconRegionManager;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end
