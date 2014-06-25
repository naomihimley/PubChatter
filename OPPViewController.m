//
//  OPPViewController.m
//  PubChatter
//
//  Created by Richard Fellure on 6/16/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import "OPPViewController.h"
#import "AppDelegate.h"
#import "ChatBoxViewController.h"

@interface OPPViewController ()<UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userAgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *sexLabel;
@property (weak, nonatomic) IBOutlet UITextView *bioLabel;
@property (weak, nonatomic) IBOutlet UILabel *sexualOrientationLabel;
@property (weak, nonatomic) IBOutlet UILabel *favDrinkLabel;
@property AppDelegate *appDelegate;

-(void)receivedInvitationForConnection: (NSNotification *)notification;


@end

@implementation OPPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.userNameLabel.text = [self.user objectForKey:@"name"];
    self.userAgeLabel.text = [NSString stringWithFormat:@"%@",[self.user objectForKey:@"age"]];

    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receivedInvitationForConnection:) name:@"MCReceivedInvitation" object:nil];

    if ([self.user [@"gender"] isEqual:@0])
    {
        self.sexLabel.text = @"F";
    }
    else if ([self.user[@"gender"] isEqual:@1])
    {
        self.sexLabel.text = @"M";
    }
    else if ([self.user [@"gender"] isEqual:@2])
    {
        self.sexLabel.text = @"Other";
        [self.sexLabel sizeToFit];
    }
    else
    {
        self.sexLabel.text = @"";
    }

    if ([self.user [@"sexualOrientation"] isEqual:@0])
    {
        self.sexualOrientationLabel.text = @"Interested In Men";
        [self.sexualOrientationLabel sizeToFit];
    }
    else if ([self.user[@"sexualOrientation"] isEqual:@1])
    {
        self.sexualOrientationLabel.text = @"Interested In Women";
        [self.sexualOrientationLabel sizeToFit];
    }
    else if ([self.user [@"sexualOrientation"] isEqual:@2])
    {
        self.sexualOrientationLabel.text = @"Bisexual";
        [self.sexualOrientationLabel sizeToFit];
    }
    else
    {
        self.sexualOrientationLabel.text = @"";
    }

    self.favDrinkLabel.text = [self.user objectForKey:@"favoriteDrink"];

    PFFile *file = [self.user objectForKey:@"picture"];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        self.imageView.image = [UIImage imageWithData:data];
    }];

    self.bioLabel.text = [self.user objectForKey:@"bio"];

    self.chatArray = [NSMutableArray array];

    self.chatDictionaryArray = [NSMutableArray array];
}

#pragma mark - Alert Showing Invitation to join Session

-(void)receivedInvitationForConnection:(NSNotification *)notification
{
    MCPeerID *peerID = [[notification userInfo]objectForKey:@"peerID"];
    NSString *alertViewString = [NSString stringWithFormat:@"%@ wants to connect and chat with you", peerID.displayName];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:alertViewString message:nil delegate:self cancelButtonTitle:@"Decline" otherButtonTitles:@"Accept", nil];
    [alertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    BOOL accept = (buttonIndex != alertView.cancelButtonIndex);

    void (^invitationHandler)(BOOL, MCSession *) = [self.appDelegate.mcManager.invitationHandlerArray objectAtIndex:0];
    invitationHandler(accept, self.appDelegate.mcManager.session);
}

- (IBAction)onButtonPressedDismissVC:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
