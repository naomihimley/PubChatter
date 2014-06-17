//
//  EditProfileViewController.m
//  PubChatter
//
//  Created by Yeah Right on 6/16/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import "EditProfileViewController.h"
#import <Parse/Parse.h>

@interface EditProfileViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (nonatomic, strong) UIImagePickerController *cameraController;
@property (weak, nonatomic) IBOutlet UITextField *ageLabel;
@property (weak, nonatomic) IBOutlet UITextField *favoriteDrinkLabel;
@property (weak, nonatomic) IBOutlet UITextView *bioTextView;
@property (weak, nonatomic) IBOutlet UIImageView *pictureView;
@property UIImage *profileImageTaken;
@property (weak, nonatomic) IBOutlet UIButton *femaleGenderButton;
@property (weak, nonatomic) IBOutlet UIButton *maleGenderButton;
@property (weak, nonatomic) IBOutlet UIButton *otherGenderButton;
@property (weak, nonatomic) IBOutlet UIButton *seekingMenButton;
@property (weak, nonatomic) IBOutlet UIButton *seekingWomenButton;
@property (weak, nonatomic) IBOutlet UIButton *seekingBothButton;


@end

@implementation EditProfileViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTextFields];
    self.profileImageTaken = [[UIImage alloc]init];
    PFFile *file = [[PFUser currentUser]objectForKey:@"picture"];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
     {
         self.pictureView.layer.cornerRadius = self.pictureView.bounds.size.width /2;
         self.pictureView.layer.masksToBounds = YES;
         self.pictureView.layer.borderWidth = 0;
         self.pictureView.image = [UIImage imageWithData:data];
     }];
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


- (void)setTextFields
{
     self.nameTextField.text = [[PFUser currentUser]objectForKey:@"username"];
     if ([[PFUser currentUser]objectForKey: @"bio"])
     {
         self.bioTextView.text = [[PFUser currentUser]objectForKey:@"bio"];
     }
     else
     {
         self.bioTextView.text = @"";
     }
     if ([[PFUser currentUser]objectForKey: @"age"]) {
         self.ageLabel.text = [[PFUser currentUser]objectForKey: @"age"];
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

}
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
         [self setImage];
     }];
}
- (void)setImage
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
                  }
                  else{
                      NSLog(@"Error: %@ %@", error, [error userInfo]);
                  }
              }];
         }
     }];
}

- (IBAction)onEditButtonPressed:(id)sender
{
    [self presentViewController:self.cameraController animated:NO completion:^{}];
}
- (IBAction)onDoneButtonPressed:(id)sender
{
    NSData *imgData = UIImagePNGRepresentation(self.profileImageTaken);
    PFFile *imgFile = [PFFile fileWithData:imgData];
    if (self.ageLabel.text != nil) {
        [[PFUser currentUser]setObject:self.ageLabel.text forKey:@"age"];
    }
    if (self.bioTextView.text != nil) {
        [[PFUser currentUser]setObject:self.bioTextView.text forKey:@"bio"];
    }
    if (self.favoriteDrinkLabel.text != nil) {
        [[PFUser currentUser]setObject:self.favoriteDrinkLabel.text forKey:@"favoriteDrink"];
    }
    [[PFUser currentUser]setObject:imgFile forKey:@"picture"];
    if ([self.femaleGenderButton isSelected]) {
        [[PFUser currentUser]setObject:@0 forKey:@"gender"];
    }
    else if ([self.maleGenderButton isSelected])
    {
        [[PFUser currentUser]setObject:@1 forKey:@"gender"];
    }
    else if ([self.otherGenderButton isSelected])
    {
        [[PFUser currentUser]setObject:@2 forKey:@"gender"];
    }
    if ([self.seekingMenButton isSelected]) {
        [[PFUser currentUser]setObject:@0 forKey:@"sexualOrientation"];
    }
    else if ([self.seekingWomenButton isSelected])
    {
        [[PFUser currentUser]setObject:@1 forKey:@"sexualOrientation"];
    }
    else if ([self.seekingBothButton isSelected])
    {
        [[PFUser currentUser]setObject:@2 forKey:@"sexualOrientation"];
    }
    if (![self.nameTextField.text isEqualToString:@""])
    {
        [[PFUser currentUser] setUsername:self.nameTextField.text];
        [[PFUser currentUser] saveInBackground];
    }
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (IBAction)onFemaleGenderButtonPressed:(id)sender
{
    [self.femaleGenderButton setSelected:YES];
    [self.maleGenderButton setSelected:NO];
    [self.otherGenderButton setSelected:NO];
}
- (IBAction)onMaleGenderButtonPressed:(id)sender
{
    [self.femaleGenderButton setSelected:NO];
    [self.maleGenderButton setSelected:YES];
    [self.otherGenderButton setSelected:NO];
}
- (IBAction)onOtherGenderButtonPressed:(id)sender
{
    [self.femaleGenderButton setSelected:NO];
    [self.maleGenderButton setSelected:NO];
    [self.otherGenderButton setSelected:YES];
}
- (IBAction)onSeekingMenButtonPressed:(id)sender
{
    [self.seekingMenButton setSelected:YES];
    [self.seekingWomenButton setSelected:NO];
    [self.seekingBothButton setSelected:NO];
}
- (IBAction)onSeekingWomenButtonPressed:(id)sender
{
    [self.seekingMenButton setSelected:NO];
    [self.seekingWomenButton setSelected:YES];
    [self.seekingBothButton setSelected:NO];

}
- (IBAction)onSeekingBothButtonPressed:(id)sender
{
    [self.seekingMenButton setSelected:NO];
    [self.seekingWomenButton setSelected:NO];
    [self.seekingBothButton setSelected:YES
     ];
}

@end
