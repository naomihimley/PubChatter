//
//  EditProfileViewController.m
//  PubChatter
//
//  Created by Yeah Right on 6/16/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import "EditProfileViewController.h"
#import <Parse/Parse.h>

@interface EditProfileViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UIPickerViewDataSource,UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (nonatomic, strong) UIImagePickerController *cameraController;
@property (weak, nonatomic) IBOutlet UITextField *ageLabel;
@property (weak, nonatomic) IBOutlet UITextField *favoriteDrinkLabel;
@property (weak, nonatomic) IBOutlet UITextView *bioTextView;
@property (weak, nonatomic) IBOutlet UIImageView *pictureView;
@property UIImage *profileImageTaken;
@property (weak, nonatomic) IBOutlet UIPickerView *genderPicker;
@property (weak, nonatomic) IBOutlet UILabel *genderLabel;
@property (weak, nonatomic) IBOutlet UIView *pickerBackgroundView;
@property NSArray *genderArray;
@property NSArray *interestedArray;
@property NSString *genderString;
@property NSString *interestedString;

@end

@implementation EditProfileViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.genderArray = [[NSArray alloc] initWithObjects:@"Woman", @"Man", @"Other", nil];
    self.interestedArray = [[NSArray alloc] initWithObjects:@"Women", @"Men", @"Other", nil];
    self.bioTextView.delegate = self;
    self.nameTextField.clearButtonMode = UITextFieldViewModeAlways;
    self.ageLabel.clearButtonMode = UITextFieldViewModeAlways;
    self.favoriteDrinkLabel.clearButtonMode = UITextFieldViewModeAlways;
    self.profileImageTaken = [[UIImage alloc]init];
    self.cameraController = [[UIImagePickerController alloc] init];
    self.cameraController.delegate = self;
    [self.cameraController setAllowsEditing:YES];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.cameraController.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else
    {
        self.cameraController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setTextFields];
}

- (void)setTextFields
{
    PFFile *file = [[PFUser currentUser]objectForKey:@"picture"];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
     {
         self.pictureView.layer.cornerRadius = self.pictureView.bounds.size.width /2;
         self.pictureView.clipsToBounds = YES;
         self.pictureView.layer.borderWidth = 0;
         self.pictureView.image = [UIImage imageWithData:data];
     }];
    self.nameTextField.text = [[PFUser currentUser]objectForKey:@"name"];
    if ([[PFUser currentUser]objectForKey: @"bio"])
    {
        self.bioTextView.text = [[PFUser currentUser]objectForKey:@"bio"];
    }
    else
    {
        self.bioTextView.text = @"";
    }
    if ([[PFUser currentUser]objectForKey: @"age"]) {
        self.ageLabel.text = [NSString stringWithFormat: @"%@",[[PFUser currentUser]objectForKey: @"age"]];
    }
    else
    {
        self.ageLabel.text = @"enter age";
    }
    if ([[PFUser currentUser]objectForKey: @"favoriteDrink"]) {
        self.favoriteDrinkLabel.text = [[PFUser currentUser]objectForKey: @"favoriteDrink"];
    }
    else
    {
        self.favoriteDrinkLabel.text = @"favorite drink";
    }

    if ([[[PFUser currentUser]objectForKey: @"gender"] isEqualToNumber:@1]) {
        self.genderString = [[self.genderArray objectAtIndex:1] lowercaseString];
        [self.genderPicker selectRow:1 inComponent:0 animated:YES];
    }
    else if ([[[PFUser currentUser]objectForKey: @"gender"] isEqualToNumber:@0]) {
        self.genderString = [[self.genderArray objectAtIndex:0] lowercaseString];
        [self.genderPicker selectRow:0 inComponent:0 animated:YES];
    }
    else {
        self.genderString = [[self.genderArray objectAtIndex:2] lowercaseString];
        [self.genderPicker selectRow:2 inComponent:0 animated:YES];
    }


    if ([[[PFUser currentUser]objectForKey: @"sexualOrientation"] isEqualToNumber:@0]) {
        self.interestedString = [[self.interestedArray objectAtIndex:1] lowercaseString];
        [self.genderPicker selectRow:1 inComponent:1 animated:YES];
    }
    else if ([[[PFUser currentUser]objectForKey: @"sexualOrientation"] isEqualToNumber:@1]) {
        self.interestedString = [[self.interestedArray objectAtIndex:0] lowercaseString];
        [self.genderPicker selectRow:0 inComponent:1 animated:YES];
    }
    else {
        self.interestedString = [[self.interestedArray objectAtIndex:2] lowercaseString];
        [self.genderPicker selectRow:2 inComponent:1 animated:YES];
    }

    UIFont *boldFont = [UIFont boldSystemFontOfSize:18.0];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"I am a %@ interested in %@", self.genderString, self.interestedString]];
    [attrString addAttribute: NSFontAttributeName value: boldFont range: NSMakeRange(7, self.genderString.length)];
    [attrString addAttribute: NSFontAttributeName value: boldFont range: NSMakeRange(7 + self.genderString.length + 15,self.interestedString.length)];
    self.genderLabel.attributedText = attrString;
}
- (void)createUserProfileImage
{
    CGSize scale = CGSizeMake(150, 150);
    UIGraphicsBeginImageContextWithOptions(scale, NO, 0.0);
    [self.profileImageTaken drawInRect:CGRectMake(0, 0, scale.width, scale.height)];
    UIImage * resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();


    NSData *imageData = UIImagePNGRepresentation(resizedImage);
    PFFile *imageFile = [PFFile fileWithData:imageData];

    // Save PFFile
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (!error) {
             PFUser *user = [PFUser currentUser];
             [user setObject:imageFile forKey:@"picture"];
             [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
              {
                  if (!error) {
                      [self dismissViewControllerAnimated:YES completion:nil];
                      [self setTextFields];
                  }
                  else{
                      NSLog(@"Error: %@ %@", error, [error userInfo]);
                  }
              }];
         }
     }];
}

#pragma mark - UITextView Delegate Methods
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{


    if([text isEqualToString:@"\b"]){
        return YES;
    }else if([[textView text] length] - range.length + text.length > 120){

        return NO;
    }

    return YES;
}
#pragma mark - UIImagePicker Delegate Methods
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:NO completion:^
     {
         self.profileImageTaken = [info valueForKey:UIImagePickerControllerOriginalImage];
         [self createUserProfileImage];
     }];
}

#pragma mark - IBAction Button Pressed Methods
- (IBAction)onEditButtonPressed:(id)sender
{
    [self presentViewController:self.cameraController animated:NO completion:^{}];

}
- (IBAction)onDoneButtonPressed:(id)sender
{
//    NSData *imgData = UIImagePNGRepresentation(self.profileImageTaken);
//    PFFile *imgFile = [PFFile fileWithData:imgData];
//    [[PFUser currentUser]setObject:imgFile forKey:@"picture"];

    if (![self.nameTextField.text isEqualToString:@""])
    {
        [[PFUser currentUser] setObject:self.nameTextField.text forKey:@"name"];
    }
    if (self.ageLabel.text != nil) {
        NSNumber  *ageNum = [NSNumber numberWithInteger: [self.ageLabel.text integerValue]];
        [[PFUser currentUser]setObject:ageNum forKey:@"age"];
    }
    if (self.bioTextView.text != nil) {
        [[PFUser currentUser]setObject:self.bioTextView.text forKey:@"bio"];
    }
    if (self.favoriteDrinkLabel.text != nil) {
        [[PFUser currentUser]setObject:self.favoriteDrinkLabel.text forKey:@"favoriteDrink"];
    }

    [[PFUser currentUser] saveInBackground];
    [self.navigationController popToRootViewControllerAnimated:NO];
}

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    return self.genderArray.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row   forComponent:(NSInteger)component
{
    if (component == 0) {
        return [self.genderArray objectAtIndex:row];
    }
    else{
        return [self.interestedArray objectAtIndex:row];
    }
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row   inComponent:(NSInteger)component
{
    NSLog(@"Selected Row %ld", (long)row);
    switch (component) {
        case 0:
            switch(row)
                {
            case 0:
                self.genderString = [[self.genderArray objectAtIndex:0] lowercaseString];
                [[PFUser currentUser]setObject:@0 forKey:@"gender"];
                break;
            case 1:
                self.genderString = [[self.genderArray objectAtIndex:1] lowercaseString];
                [[PFUser currentUser]setObject:@1 forKey:@"gender"];
                break;
            case 2:
                self.genderString = [[self.genderArray objectAtIndex:2] lowercaseString];
                [[PFUser currentUser]setObject:@2 forKey:@"gender"];
                break;
            break;
                }
            break;
         case 1:
            switch(row)
            {
            case 0:
                self.interestedString = [[self.interestedArray objectAtIndex:0] lowercaseString];
                [[PFUser currentUser]setObject:@1 forKey:@"sexualOrientation"];
                break;
            case 1:
                self.interestedString = [[self.interestedArray objectAtIndex:1] lowercaseString];
                [[PFUser currentUser]setObject:@0 forKey:@"sexualOrientation"];
                break;
            case 2:
                    self.interestedString = [[self.interestedArray objectAtIndex:2] lowercaseString];
                    [[PFUser currentUser]setObject:@2 forKey:@"sexualOrientation"];
                break;
            }
        default:
        break;
    }
    UIFont *boldFont = [UIFont boldSystemFontOfSize:18.0];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"I am a %@ interested in %@", self.genderString, self.interestedString]];
    [attrString addAttribute: NSFontAttributeName value: boldFont range: NSMakeRange(7, self.genderString.length)];
    [attrString addAttribute: NSFontAttributeName value: boldFont range: NSMakeRange(7 + self.genderString.length + 15,self.interestedString.length)];
    self.genderLabel.attributedText = attrString;
}






@end
