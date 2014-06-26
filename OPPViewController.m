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
    self.chatArray = [NSMutableArray array];
    self.chatDictionaryArray = [NSMutableArray array];

    // Set name and age label.
    self.userNameLabel.text = [NSString stringWithFormat:@"%@, %@", [self.user objectForKey:@"name"],[self.user objectForKey:@"age"]];

    // Set gender label.
    if ([self.user [@"gender"] isEqual:@0]) {
        self.sexLabel.text = @"F";
    }
    else if ([self.user[@"gender"] isEqual:@1]) {
        self.sexLabel.text = @"M";
    }
    else if ([self.user [@"gender"] isEqual:@2]) {
        self.sexLabel.text = @"Other";
    }
    else {
        self.sexLabel.text = @"";
    }

    // Set about me.
    if ([self.user objectForKey:@"bio"]) {
        NSString *name = [self.user objectForKey:@"name"];
        UIFont *boldFont = [UIFont boldSystemFontOfSize:12.0];
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"About %@\n%@", name, [self.user objectForKey:@"bio"]]];
        [attrString addAttribute: NSFontAttributeName value: boldFont range: NSMakeRange(0, 6 + name.length)];
        self.bioLabel.attributedText = attrString;
    }
    else {
        self.bioLabel.text = @"";
    }

    // Set sexual orientation label.
    if ([self.user [@"sexualOrientation"] isEqual:@0]) {
        self.sexualOrientationLabel.text = @"Interested in: Men";
        [self.sexualOrientationLabel sizeToFit];
    }
    else if ([self.user[@"sexualOrientation"] isEqual:@1]) {
        self.sexualOrientationLabel.text = @"Interested in: Women";
        [self.sexualOrientationLabel sizeToFit];
    }
    else if ([self.user [@"sexualOrientation"] isEqual:@2]) {
        self.sexualOrientationLabel.text = @"Bisexual";
        [self.sexualOrientationLabel sizeToFit];
    }
    else {
        self.sexualOrientationLabel.text = @"";
    }

    // Set profile image.
    PFFile *file = [self.user objectForKey:@"picture"];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        self.imageView.image = [UIImage imageWithData:data];
    }];

    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receivedInvitationForConnection:) name:@"MCReceivedInvitation" object:nil];
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
