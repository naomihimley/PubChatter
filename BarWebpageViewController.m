//
//  BarWebpageViewController.m
//  PubChatter
//
//  Created by David Warner on 6/16/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import "BarWebpageViewController.h"

@interface BarWebpageViewController () <UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation BarWebpageViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    if (self.mobileURLFromSource) {
        NSURL *mobileURL = [NSURL URLWithString:self.mobileURLFromSource];
        NSURLRequest *request = [NSURLRequest requestWithURL:mobileURL];
        [self.webView loadRequest:request];
        self.webView.hidden = NO;
        NSLog(@"mobileURL");
    }
    else if (self.webURLFromSource)
    {
        NSURL *businessURL = [NSURL URLWithString:self.webURLFromSource];
        NSURLRequest *request = [NSURLRequest requestWithURL:businessURL];
        [self.webView loadRequest:request];
        self.webView.hidden = NO;
        NSLog(@"webURL");

    }
    else {
        self.webView.hidden = YES;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ appears to not have a webpage", self.placeNameFromSource] message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        NSLog(@"neither");
    }
}


@end
