//
//  OPPViewController.m
//  PubChatter
//
//  Created by Richard Fellure on 6/16/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import "OPPViewController.h"
#import "AppDelegate.h"

@interface OPPViewController ()<MCBrowserViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userAgeLabel;
@property (weak, nonatomic) IBOutlet UIButton *beginChattingButton;
@property AppDelegate *appDelegate;

@end

@implementation OPPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[self.appDelegate mcManager]setupPeerAndSessionWithDisplayName:[UIDevice currentDevice].name];//need to change to have the users profile name display and not their device name
    [self.appDelegate.mcManager advertiseSelf:YES];

}
- (IBAction)onButtonPressedSearchForConnections:(id)sender
{
    [[self.appDelegate mcManager]setupMCBrowser];
    self.appDelegate.mcManager.browser.delegate = self;
    [self presentViewController:self.appDelegate.mcManager.browser animated:YES completion:nil];

}

#pragma mark - MCBrowserDelegat methods

-(void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
    [self.appDelegate.mcManager.browser dismissViewControllerAnimated:YES completion:nil];
}

-(void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
    [self.appDelegate.mcManager.browser dismissViewControllerAnimated:YES completion:nil];
}

@end
