//
//  RightSlideoutViewController.m
//  PubChatter
//
//  Created by David Warner on 6/23/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import "RightSlideoutViewController.h"
#import <Parse/Parse.h>
#import "Rating.h"
#import "Bar.h"
#import "UIColor+DesignColors.h"
#import <CoreGraphics/CoreGraphics.h>

@interface RightSlideoutViewController ()

@property Bar *bar;
@property Rating *rating;
@property UIView *rateIndicator;
@property UILabel *label1;
@property UILabel *label2;
@property UILabel *label3;
@property UILabel *label4;
@property UILabel *label5;
@property UILabel *label6;
@property UILabel *label7;
@property CGFloat labelWidth;
@property CGFloat labelHeight;
@property (weak, nonatomic) IBOutlet UILabel *inABarLabel;
@property UIPushBehavior *pushBehavior;
@property UIDynamicItemBehavior *dynamicItemBehaviorIndicator;


-(void)userEnteredBar:(NSNotification *)notification;

@end

@implementation RightSlideoutViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(userEnteredBar:)
                                                name:@"userEnteredBar"
                                              object:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"chatBox"
                                                       object:nil
                                                     userInfo:@{@"toBeaconRegionManager": @"whatBarAmIIn"}];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self.label1 removeFromSuperview];
    [self.label2 removeFromSuperview];
    [self.label3 removeFromSuperview];
    [self.label4 removeFromSuperview];
    [self.label5 removeFromSuperview];
    [self.label6 removeFromSuperview];
    [self.label7 removeFromSuperview];
    [self.rateIndicator removeFromSuperview];

    NSLog(@"view did appear");
    [self checkIfUserisInBar];
    [self createRateIndicatorandLabels];
    [self style];
}

-(void)createRateIndicatorandLabels
{
    // Create the sliding rate indicator and add to view (eventually replace view with better-looking image)
    CGFloat indicatorWidth = 100;

    self.rateIndicator = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.size.height/2, indicatorWidth, 30)];
    self.rateIndicator.backgroundColor = [UIColor buttonColor];
    self.rateIndicator.layer.cornerRadius = 50.f;
    [self.view addSubview:self.rateIndicator];

    // Set up pan gesture recognizer
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.view addGestureRecognizer:pan];

    // Get status and nav bar height so vertical offset and height of labels can be set precisely.
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat navBarHeight = self.navigationController.navigationBar.frame.size.height;

    //Create labels
    self.labelWidth = 150;
    self.labelHeight = (self.view.frame.size.height - statusBarHeight - navBarHeight)/7;
    CGFloat verticalOffset = statusBarHeight + navBarHeight;

    self.label1 = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - (self.labelWidth/2), verticalOffset, self.labelWidth, self.labelHeight)];
    self.label1.text = @"   Bro";
    self.label1.textColor = [UIColor buttonColor];
    self.label1.backgroundColor = [UIColor clearColor];
    self.label1.layer.borderWidth = 2.0f;
    self.label1.layer.borderColor = [[UIColor buttonColor] CGColor];
    self.label1.layer.cornerRadius = 5.0f;
    [self.view addSubview:self.label1];
    verticalOffset = verticalOffset + self.labelHeight;

    self.label2 = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - (self.labelWidth/2), verticalOffset, self.labelWidth, self.labelHeight)];
    self.label2.text = @"   Artsy";
    self.label2.textColor = [UIColor buttonColor];
    self.label2.backgroundColor = [UIColor clearColor];
    self.label2.layer.borderWidth = 2.0f;
    self.label2.layer.borderColor = [[UIColor buttonColor] CGColor];
    self.label2.layer.cornerRadius = 5.0f;
    [self.view addSubview:self.label2];
    verticalOffset = verticalOffset + self.labelHeight;

    self.label3 = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - (self.labelWidth/2), verticalOffset, self.labelWidth, self.labelHeight)];
    self.label3.text = @"   Chill";
    self.label3.textColor = [UIColor buttonColor];
    self.label3.backgroundColor = [UIColor clearColor];
    self.label3.layer.borderWidth = 2.0f;
    self.label3.layer.borderColor = [[UIColor buttonColor] CGColor];
    self.label3.layer.cornerRadius = 5.0f;
    [self.view addSubview:self.label3];
    verticalOffset = verticalOffset + self.labelHeight;

    self.label4 = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - (self.labelWidth/2), verticalOffset, self.labelWidth, self.labelHeight)];
    self.label4.text = @"   Hipster";
    self.label4.textColor = [UIColor buttonColor];
    self.label4.backgroundColor = [UIColor clearColor];
    self.label4.layer.borderWidth = 2.0f;
    self.label4.layer.borderColor = [[UIColor buttonColor] CGColor];
    self.label4.layer.cornerRadius = 5.0f;    [self.view addSubview:self.label4];
    verticalOffset = verticalOffset + self.labelHeight;

    self.label5 = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - (self.labelWidth/2), verticalOffset, self.labelWidth, self.labelHeight)];
    self.label5.text = @"   Classy";
    self.label5.textColor = [UIColor buttonColor];
    self.label5.backgroundColor = [UIColor clearColor];
    self.label5.layer.borderWidth = 2.0f;
    self.label5.layer.borderColor = [[UIColor buttonColor] CGColor];
    self.label5.layer.cornerRadius = 5.0f;    [self.view addSubview:self.label5];
    verticalOffset = verticalOffset + self.labelHeight;

    self.label6 = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - (self.labelWidth/2), verticalOffset, self.labelWidth, self.labelHeight)];
    self.label6.text = @"   Clubby";
    self.label6.textColor = [UIColor buttonColor];
    self.label6.backgroundColor = [UIColor clearColor];
    self.label6.layer.borderWidth = 2.0f;
    self.label6.layer.borderColor = [[UIColor buttonColor] CGColor];
    self.label6.layer.cornerRadius = 5.0f;    [self.view addSubview:self.label6];
    verticalOffset = verticalOffset + self.labelHeight;

    self.label7 = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - (self.labelWidth/2), verticalOffset, self.labelWidth, self.labelHeight)];
    self.label7.text = @"   Dive";
    self.label7.textColor = [UIColor buttonColor];
    self.label7.backgroundColor = [UIColor clearColor];
    self.label7.layer.borderWidth = 2.0f;
    self.label7.layer.borderColor = [[UIColor buttonColor] CGColor];
    self.label7.layer.cornerRadius = 5.0f;
    [self.view addSubview:self.label7];
}

- (void)handlePan:(UIPanGestureRecognizer *)pan
{
    // Lock rate indicator x location and make y location the locationinview of pan gesture recognizer. Creates the up/down sliding effect.
    self.rateIndicator.center = CGPointMake(self.rateIndicator.center.x, [pan locationInView:self.view].y);

    // Slide out the label views when the indicator view is in their vertical range.
    if ([pan locationInView:self.view].y > self.label1.frame.origin.y && [pan locationInView:self.view].y < self.label1.frame.origin.y + self.label1.frame.size.height) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationDelay:0.0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];

        self.label1.frame = CGRectMake(self.view.frame.size.width - self.labelWidth, self.label1.frame.origin.y, self.labelWidth, self.labelHeight);
        self.label1.backgroundColor = [UIColor buttonColor];
        self.label1.textColor = [UIColor blackColor];
        [UIView commitAnimations];
    }
    else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationDelay:0.0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];

        self.label1.frame = CGRectMake(self.view.frame.size.width - (self.labelWidth/2), self.label1.frame.origin.y, self.labelWidth, self.labelHeight);
        self.label1.backgroundColor = [UIColor clearColor];
        self.label1.textColor = [UIColor buttonColor];

        [UIView commitAnimations];
    }

    if ([pan locationInView:self.view].y > self.label2.frame.origin.y && [pan locationInView:self.view].y < self.label2.frame.origin.y + self.label2.frame.size.height) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationDelay:0.0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];

        self.label2.frame = CGRectMake(self.view.frame.size.width - self.labelWidth, self.label2.frame.origin.y, self.labelWidth, self.labelHeight);
        self.label2.backgroundColor = [UIColor buttonColor];
        self.label2.textColor = [UIColor blackColor];

        [UIView commitAnimations];
    }
    else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationDelay:0.0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];

        self.label2.frame = CGRectMake(self.view.frame.size.width - (self.labelWidth/2), self.label2.frame.origin.y, self.labelWidth, self.labelHeight);
        self.label2.backgroundColor = [UIColor clearColor];
        self.label2.textColor = [UIColor buttonColor];

        [UIView commitAnimations];

    }

    if ([pan locationInView:self.view].y > self.label3.frame.origin.y && [pan locationInView:self.view].y < self.label3.frame.origin.y + self.label3.frame.size.height) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationDelay:0.0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];

        self.label3.frame = CGRectMake(self.view.frame.size.width - self.labelWidth, self.label3.frame.origin.y, self.labelWidth, self.labelHeight);
        self.label3.backgroundColor = [UIColor buttonColor];
        self.label3.textColor = [UIColor blackColor];

        [UIView commitAnimations];
    }
    else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationDelay:0.0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];

        self.label3.frame = CGRectMake(self.view.frame.size.width - (self.labelWidth/2), self.label3.frame.origin.y, self.labelWidth, self.labelHeight);
        self.label3.backgroundColor = [UIColor clearColor];
        self.label3.textColor = [UIColor buttonColor];
        [UIView commitAnimations];
        
    }

    if ([pan locationInView:self.view].y > self.label4.frame.origin.y && [pan locationInView:self.view].y < self.label4.frame.origin.y + self.label4.frame.size.height) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationDelay:0.0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];

        self.label4.frame = CGRectMake(self.view.frame.size.width - self.labelWidth, self.label4.frame.origin.y, self.labelWidth, self.labelHeight);
        self.label4.backgroundColor = [UIColor buttonColor];
        self.label4.textColor = [UIColor blackColor];
        [UIView commitAnimations];
    }
    else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationDelay:0.0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];

        self.label4.frame = CGRectMake(self.view.frame.size.width - (self.labelWidth/2), self.label4.frame.origin.y, self.labelWidth, self.labelHeight);
        self.label4.backgroundColor = [UIColor clearColor];
        self.label4.textColor = [UIColor buttonColor];
        [UIView commitAnimations];

    }

    if ([pan locationInView:self.view].y > self.label5.frame.origin.y && [pan locationInView:self.view].y < self.label5.frame.origin.y + self.label5.frame.size.height) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationDelay:0.0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];

        self.label5.frame = CGRectMake(self.view.frame.size.width - self.labelWidth, self.label5.frame.origin.y, self.labelWidth, self.labelHeight);
        self.label5.backgroundColor = [UIColor buttonColor];
        self.label5.textColor = [UIColor blackColor];
        [UIView commitAnimations];
    }
    else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationDelay:0.0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];

        self.label5.frame = CGRectMake(self.view.frame.size.width - (self.labelWidth/2), self.label5.frame.origin.y, self.labelWidth, self.labelHeight);
        self.label5.backgroundColor = [UIColor clearColor];
        self.label5.textColor = [UIColor buttonColor];
        [UIView commitAnimations];
        
    }

    if ([pan locationInView:self.view].y > self.label6.frame.origin.y && [pan locationInView:self.view].y < self.label6.frame.origin.y + self.label6.frame.size.height) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationDelay:0.0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];

        self.label6.frame = CGRectMake(self.view.frame.size.width - self.labelWidth, self.label6.frame.origin.y, self.labelWidth, self.labelHeight);
        self.label6.backgroundColor = [UIColor buttonColor];
        self.label6.textColor = [UIColor blackColor];
        [UIView commitAnimations];
    }
    else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationDelay:0.0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];

        self.label6.frame = CGRectMake(self.view.frame.size.width - (self.labelWidth/2), self.label6.frame.origin.y, self.labelWidth, self.labelHeight);
        self.label6.backgroundColor = [UIColor clearColor];
        self.label6.textColor = [UIColor buttonColor];
        [UIView commitAnimations];
    }
    if ([pan locationInView:self.view].y > self.label7.frame.origin.y && [pan locationInView:self.view].y < self.label7.frame.origin.y + self.label7.frame.size.height) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationDelay:0.0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];

        self.label7.frame = CGRectMake(self.view.frame.size.width - self.labelWidth, self.label7.frame.origin.y, self.labelWidth, self.labelHeight);
        self.label7.backgroundColor = [UIColor buttonColor];
        self.label7.textColor = [UIColor blackColor];
        [UIView commitAnimations];
    }
    else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationDelay:0.0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];

        self.label7.frame = CGRectMake(self.view.frame.size.width - (self.labelWidth/2), self.label7.frame.origin.y, self.labelWidth, self.labelHeight);
        self.label7.backgroundColor = [UIColor clearColor];
        self.label7.textColor = [UIColor buttonColor];
        [UIView commitAnimations];
    }
}

#pragma mark - Notifications
//iBeacon Notification, sends the BarName on region entry and 'PubChat' on region exit
- (void)userEnteredBar: (NSNotification *)notification
{
    NSString *barName = [[notification userInfo] objectForKey:@"barName"];
    if ([barName isEqualToString:@"PubChat"])
    {
        self.inABarLabel.text = @"Not in a Bar";
    }
    else
    {
        self.inABarLabel.text = barName;
    }
}

#pragma mark - Parse Methods
-(void)checkIfUserisInBar
{
    PFQuery *queryForBar = [PFQuery queryWithClassName:@"Bar"];
    [queryForBar whereKey:@"usersInBar" equalTo:[PFUser currentUser]];
    [queryForBar findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects firstObject]) {
            self.bar = [objects firstObject];
            NSLog(@"they are in this bar: %@", [self.bar objectForKey:@"barName"]);
            self.inABarLabel.text = [self.bar objectForKey:@"barName"];
            [self checkIfUserHasRatedBar];
        }
        else
        {
            self.inABarLabel.text = @"Not in a Bar";
        }
    }];
}

-(void)checkIfUserHasRatedBar
{
    PFQuery *queryForRating = [PFQuery queryWithClassName:@"Rating"];
    [queryForRating whereKey:@"user" equalTo:[PFUser currentUser]];
    [queryForRating findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects firstObject])
        {
            self.rating = [objects firstObject];
        }
    }];
}

#pragma mark - Button Pressed Methods
//- (IBAction)onRateButtonPressed:(id)sender
//{
//    if (self.rating) {
//        NSInteger rtg= @(self.sliderOutlet.value).intValue;
//        NSNumber *rating = @(rtg);
//        [self.rating setObject:rating forKey:@"rating"];
//        [self.rating saveInBackground];
//    }
//
//    else
//    {
//        NSInteger rtg= @(self.sliderOutlet.value).intValue;
//        NSNumber *rating = @(rtg);
//        Rating *barRating = [Rating objectWithClassName:@"Rating"];
//        [barRating setObject:rating forKey:@"rating"];
//        [barRating setObject:[PFUser currentUser] forKey:@"user"];
//        [barRating setObject:self.bar forKey:@"bar"];
//        [barRating saveInBackground];
//    }
//}

#pragma mark - Style Method
- (void)style
{
    self.inABarLabel.textColor = [UIColor nameColor];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"river"]];
}

@end
