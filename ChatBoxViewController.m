//
//  ChatBoxViewController.m
//  PubChatter
//
//  Created by Richard Fellure on 6/16/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import "ChatBoxViewController.h"
#import "AppDelegate.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface ChatBoxViewController ()<UITextFieldDelegate, MCSessionDelegate>
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
        NSLog(@"%@", [error localizedDescription]);
    }

    [self.chatTextView setText:[self.chatTextView.text stringByAppendingString:[NSString stringWithFormat:@"I wrote:\n%@\n\n", self.chatTextField.text]]];
    NSLog(@"sent data");
    self.chatTextField.text = @"";
    [self.chatTextField resignFirstResponder];
}

-(void)didReceiveDataWithNotification:(NSNotification *)notification
{
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;

    NSLog(@"got data");

    NSData *receivedData = [[notification userInfo] objectForKey:@"data"];
    NSString *receivedText = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];

    [self.chatTextView performSelectorOnMainThread:@selector(setText:) withObject:[self.chatTextView.text stringByAppendingString:[NSString stringWithFormat:@"%@:\n%@\n\n", peerDisplayName, receivedText]] waitUntilDone:NO];
}

//-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
//{
//    NSDictionary *dictionary = @{@"data": data,
//                                 @"peerID": peerID};
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidReceiveDataNotification"
//                                                        object:nil
//                                                      userInfo:dictionary];
//}

@end
