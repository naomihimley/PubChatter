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
@property NSMutableArray *connectedUserDevices;
@property (weak, nonatomic) IBOutlet UIButton *searchForConnectionButton;

-(void)peerDidChangeStateWithNotification: (NSNotification *)notification;
@end

@implementation OPPViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.connectedUserDevices)
    {
        [self.beginChattingButton setEnabled:NO];
        [self.searchForConnectionButton setEnabled:YES];
    }
    else
    {
        [self.searchForConnectionButton setEnabled:NO];
        [self.beginChattingButton setEnabled:YES];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    PFUser *currentUser = [PFUser currentUser];

    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[self.appDelegate mcManager]setupPeerAndSessionWithDisplayName:[currentUser objectForKey:@"username"]];
    [self.appDelegate.mcManager advertiseSelf:YES];

    self.userNameLabel.text = [self.user objectForKey:@"username"];

    self.connectedUserDevices = [NSMutableArray array];
}

- (IBAction)onButtonPressedSearchForConnections:(id)sender
{
    [[self.appDelegate mcManager]setupMCBrowser];
    self.appDelegate.mcManager.browser.delegate = self;
    [self presentViewController:self.appDelegate.mcManager.browser animated:YES completion:nil];
}

#pragma mark - MCBrowserDelegate methods

-(void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
    [self.appDelegate.mcManager.browser dismissViewControllerAnimated:YES completion:nil];
}

-(void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
    [self.appDelegate.mcManager.browser dismissViewControllerAnimated:YES completion:nil];
}

-(void)peerDidChangeStateWithNotification:(NSNotification *)notification
{
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
    MCSessionState state = [[[notification userInfo] objectForKey:@"state"]intValue];

    if (state != MCSessionStateConnecting)
    {
        if (state == MCSessionStateConnected)
        {
            [self.connectedUserDevices addObject:peerDisplayName];
        }

        else if (state == MCSessionStateNotConnected)
        {
            if (self.connectedUserDevices.count > 0) {
                int indexOfPeer = [self.connectedUserDevices indexOfObject:peerDisplayName];
                [self.connectedUserDevices removeObjectAtIndex:indexOfPeer];
            }
        }
    }
}

@end
