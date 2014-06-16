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

    if (self.urlFromSource) {
        NSURLRequest *request = [NSURLRequest requestWithURL:self.urlFromSource];
        [self.webView loadRequest:request];
        self.webView.hidden = NO;
    }
    else
    {
        self.webView.hidden = YES;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ appears to not have a webpage", self.placeNameFromSource] message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
}


@end
