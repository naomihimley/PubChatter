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
@property (weak, nonatomic) IBOutlet UILabel *sexLabel;

-(void)peerDidChangeStateWithNotification: (NSNotification *)notification;
@end

@implementation OPPViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.connectedUserDevices.count == 0)
    {
        [self.beginChattingButton setEnabled:NO];
        [self.searchForConnectionButton setEnabled:YES];
    }
    else if (self.connectedUserDevices.count > 0)
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
    self.userAgeLabel.text = [self.user objectForKey:@"age"];
    self.sexLabel.text = [self.user objectForKey:@"gender"];

    self.connectedUserDevices = [NSMutableArray array];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(peerDidChangeStateWithNotification:) name:@"MCDidChangeStateNotification" object:nil];
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
            [self.beginChattingButton setEnabled:YES];
            [self.searchForConnectionButton setEnabled:NO];
        }

        else if (state == MCSessionStateNotConnected)
        {
            if (self.connectedUserDevices.count > 0)
            {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Connection to User Lost" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];

                [self.connectedUserDevices removeObjectAtIndex:[self.connectedUserDevices indexOfObject:peerDisplayName]];

                [self.beginChattingButton setEnabled:NO];
                [self.searchForConnectionButton setEnabled:YES];

                NSLog(@"%@", self.connectedUserDevices);
            }
        }
    }
}

@end
