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
#import "UIColor+DesignColors.h"

@interface OPPViewController ()<UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sexLabel;
@property (weak, nonatomic) IBOutlet UITextView *bioLabel;
@property (weak, nonatomic) IBOutlet UILabel *sexualOrientationLabel;
@property (weak, nonatomic) IBOutlet UILabel *favDrinkLabel;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UIView *backgroundLayoutView;
@property AppDelegate *appDelegate;

-(void)receivedInvitationForConnection: (NSNotification *)notification;


@end

@implementation OPPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.chatArray = [NSMutableArray array];
    self.chatDictionaryArray = [NSMutableArray array];

    self.userNameLabel.textColor =[UIColor nameColor];
    self.navBar.backgroundColor = [UIColor navBarColor];
    self.backgroundLayoutView.backgroundColor = [[UIColor backgroundColor]colorWithAlphaComponent:0.95f];
    self.sexualOrientationLabel.textColor = [UIColor whiteColor];
    self.sexLabel.textColor = [UIColor whiteColor];
    self.bioLabel.editable = YES;
    self.bioLabel.textColor = [UIColor whiteColor];
    self.bioLabel.editable = NO;
    self.favDrinkLabel.textColor = [UIColor whiteColor];
    self.bioLabel.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor blackColor];

    // Set name and age label.
    self.userNameLabel.text = [self.user objectForKey:@"name"];

    // Set gender label.
    if ([self.user [@"gender"] isEqual:@0] && [self.user objectForKey:@"age"])
    {
        self.sexLabel.text = [NSString stringWithFormat:@"%@, female", [self.user objectForKey:@"age"]];
        [self.sexLabel sizeToFit];
    }
    else if ([self.user[@"gender"] isEqual:@1] && [self.user objectForKey:@"age"])
    {
       self.sexLabel.text = [NSString stringWithFormat:@"%@, male", [self.user objectForKey:@"age"]];
        [self.sexLabel sizeToFit];
    }
    else if ([self.user [@"gender"] isEqual:@2] && [self.user objectForKey:@"age"])
    {
       self.sexLabel.text = [NSString stringWithFormat:@"%@, other", [self.user objectForKey:@"age"]];
        [self.sexLabel sizeToFit];
    }
    else if ([self.user [@"gender"] isEqual:@0])
    {
        self.sexLabel.text = @"male";
    }
    else if ([self.user [@"gender"] isEqual:@1])
    {
         self.sexLabel.text = @"female";
    }
    else if ([self.user [@"gender"] isEqual:@2])
    {
         self.sexLabel.text = @"other";
    }
    else if ([self.user objectForKey:@"age"])
    {
        self.sexLabel.text = [NSString stringWithFormat:@"%@",[self.user objectForKey:@"age"]];
    }
    else
    {
        self.sexLabel.text = @"No Info";
    }

    // Set about me.
    if ([self.user objectForKey:@"bio"])
    {
        UIColor *color = [UIColor whiteColor];
        NSString *name = [self.user objectForKey:@"name"];
        UIFont *boldFont = [UIFont boldSystemFontOfSize:12.0];
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"About %@\n%@", name, [self.user objectForKey:@"bio"]]];
        [attrString addAttribute: NSFontAttributeName value: boldFont range: NSMakeRange(0, 6 + name.length)];
        [attrString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, attrString.length)];
        self.bioLabel.attributedText = attrString;
    }
    else
    {
        self.bioLabel.text = @"No Bio Info";
    }

    // Set sexual orientation label.
    if ([self.user [@"sexualOrientation"] isEqual:@0])
    {
        self.sexualOrientationLabel.text = @"Interested in: Men";
        [self.sexualOrientationLabel sizeToFit];
    }
    else if ([self.user[@"sexualOrientation"] isEqual:@1])
    {
        self.sexualOrientationLabel.text = @"Interested in: Women";
        [self.sexualOrientationLabel sizeToFit];
    }
    else if ([self.user [@"sexualOrientation"] isEqual:@2])
    {
        self.sexualOrientationLabel.text = @"Bisexual";
        [self.sexualOrientationLabel sizeToFit];
    }
    else
    {
        self.sexualOrientationLabel.text = @"No Info";
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
