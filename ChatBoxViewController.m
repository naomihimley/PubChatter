//
//  ChatBoxViewController.m
//  PubChatter
//
//  Created by Richard Fellure on 6/16/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import "ChatBoxViewController.h"
#import "AppDelegate.h"

@interface ChatBoxViewController ()<UITextFieldDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *chatTextField;
@property (weak, nonatomic) IBOutlet UITextView *chatTextView;
@property AppDelegate *appDelegate;

-(void)didReceiveDataWithNotification: (NSNotification *)notification;
-(void)sendMyMessage;

@end

@implementation ChatBoxViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDataWithNotification:)
                                                 name:@"MCDidReceiveDataNotification"
                                               object:nil];

    self.chatTextField.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    for (NSString *chat in self.chatArray)
    {
        self.chatTextView.text = chat;
    }
}

- (IBAction)onButtonPressedCancelSendingChat:(id)sender
{
    [self.chatTextField resignFirstResponder];
}

- (IBAction)onButtonPressedSendChat:(id)sender
{
    [self sendMyMessage];
}

#pragma mark - TextField Delegat method

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self sendMyMessage];
    return YES;
}

#pragma mark - Helper method implementation

-(void)sendMyMessage
{
    NSData *dataToSend = [self.chatTextField.text dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *peerToSendTo = self.appDelegate.mcManager.session.connectedPeers;
    NSError *error;

    [self.appDelegate.mcManager.session sendData:dataToSend
                                         toPeers:peerToSendTo
                                        withMode:MCSessionSendDataReliable
                                           error:&error];
    if (error)
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Connection to User has been lost"
                                                           message:nil
                                                          delegate:self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil, nil];
        [alertView show];
    }

    else
    {
        NSString *chatString = [NSString stringWithFormat:@"I wrote:\n%@\n\n", self.chatTextField.text];
        [self.chatTextView setText:[self.chatTextView.text stringByAppendingString:chatString]];
        [self.chatArray addObject:chatString];

        self.chatTextField.text = @"";
    }
    
    [self.chatTextField resignFirstResponder];
}

-(void)didReceiveDataWithNotification:(NSNotification *)notification
{
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;

    NSData *receivedData = [[notification userInfo] objectForKey:@"data"];
    NSString *receivedText = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];

    NSString *chatString = [NSString stringWithFormat:@"%@:\n%@\n\n", peerDisplayName, receivedText];
    [self.chatTextView performSelectorOnMainThread:@selector(setText:) withObject:[self.chatTextView.text stringByAppendingString:chatString] waitUntilDone:NO];

    [self.chatArray addObject:chatString];
}

# pragma mark - Disconnect from session

- (IBAction)onButtonPressedEndSession:(id)sender
{
    [self.appDelegate.mcManager.session disconnect];
}

@end
