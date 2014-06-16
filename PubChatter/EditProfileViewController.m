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
@property (nonatomic, strong) UIImagePickerController *cameraController;
@property (weak, nonatomic) IBOutlet UITextField *ageLabel;
@property (weak, nonatomic) IBOutlet UITextField *genderLabel;
@property (weak, nonatomic) IBOutlet UITextField *sexualOrientationLabel;
@property (weak, nonatomic) IBOutlet UITextField *favoriteDrinkLabel;
@property (weak, nonatomic) IBOutlet UITextView *bioTextView;
@property (weak, nonatomic) IBOutlet UIImageView *pictureView;
@property UIImage *profileImageTaken;

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
             self.ageLabel.text = object[@"age"];
             self.genderLabel.text = object[@"gender"];
             self.bioTextView.text = object[@"bio"];
             self.sexualOrientationLabel.text = object[@"sexualOrientation"];
             self.favoriteDrinkLabel.text = object[@"favoriteDrinkLabel"];
         } else {
             // Did not find any user for the current user
             NSLog(@"Error in EditView: %@", error);
         }
     }];
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
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
             object[@"age"] = self.ageLabel.text;
             object[@"gender"] = self.genderLabel.text;
             object[@"bio"] = self.bioTextView.text;
             object[@"picture"] = imgFile;
             object[@"favoriteDrink"]= self.favoriteDrinkLabel.text;
             object[@"sexualOrientation"]= self.sexualOrientationLabel.text;

             [object saveInBackground];
         } else {
             // Did not find any user for the current user
             NSLog(@"Error in EditView: %@", error);
         }
         [self dismissViewControllerAnimated:YES completion:nil];
     }];
}

@end
