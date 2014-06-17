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
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    [query whereKey:@"username" equalTo:[[PFUser currentUser] objectForKey:@"username"]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error)
     {
         if (!error)
         {
             self.nameTextField.text = object[@"username"];
             if (object[@"bio"])
             {
                 self.bioTextView.text = object[@"bio"];
             }
             else
             {
                 self.bioTextView.text = @"Enter your 120 character bio here";
             }
             if (object[@"age"]) {
                 self.ageLabel.text = object[@"age"];
             }
             else
             {
                 self.ageLabel.text = @"enter age";
             }
             if (object[@"favoriteDrink"]) {
                 self.favoriteDrinkLabel.text = object[@"favoriteDrink"];
             }
             else
             {
                 self.favoriteDrinkLabel.text = @"favorite drink";
             }
         }
         else {
             NSLog(@"Error in EditView: %@", error);
         }
     }];
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
    [self presentViewController:self.cameraController animated:NO completion:nil];

}
- (IBAction)onDoneButtonPressed:(id)sender
{
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    [query whereKey:@"username" equalTo:[[PFUser currentUser] objectForKey:@"username"]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error)
     {
         if (!error)
         {
             NSData *imgData = UIImagePNGRepresentation(self.profileImageTaken);
             PFFile *imgFile = [PFFile fileWithData:imgData];
             object[@"username"] = self.nameTextField.text;
             object[@"age"] = self.ageLabel.text;
             object[@"bio"] = self.bioTextView.text;
             object[@"picture"] = imgFile;
             object[@"favoriteDrink"]= self.favoriteDrinkLabel.text;
             if ([self.femaleGenderButton isSelected]) {
                 object[@"gender"] = @0;
             }
             else if ([self.maleGenderButton isSelected])
             {
                 object[@"gender"] = @1;
             }
             else if ([self.otherGenderButton isSelected])
             {
                 object[@"gender"] = @2;
             }
             if ([self.seekingMenButton isSelected]) {
                 object[@"sexualOrientation"] = @0;
             }
             else if ([self.seekingWomenButton isSelected])
             {
                 object[@"sexualOrientation"] = @1;
             }
             else if ([self.seekingBothButton isSelected])
             {
                 object[@"sexualOrientation"] = @2;
             }
             [object saveInBackground];
         } else {
             // Did not find any user for the current user
             NSLog(@"Error in EditView: %@", error);
         }
         [[PFUser currentUser] setUsername:self.nameTextField.text];
         [[PFUser currentUser] saveInBackground];
         [self dismissViewControllerAnimated:YES completion:nil];
     }];
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
