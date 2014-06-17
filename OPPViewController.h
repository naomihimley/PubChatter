//
//  OPPViewController.h
//  PubChatter
//
//  Created by Richard Fellure on 6/16/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface OPPViewController : UIViewController

@property PFUser *user;
@property NSMutableArray *chatArray;
@end
