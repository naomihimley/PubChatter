//
//  EditProfileViewController.m
//  PubChatter
//
//  Created by Yeah Right on 6/16/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import "EditProfileViewController.h"
#import <Parse/Parse.h>
#import "UIColor+DesignColors.h"
#import "CustomCollectionViewCell.h"

@interface EditProfileViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UIPickerViewDataSource,UIPickerViewDelegate, UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (nonatomic, strong) UIImagePickerController *cameraController;
@property (weak, nonatomic) IBOutlet UITextField *ageLabel;
@property (weak, nonatomic) IBOutlet UITextField *favoriteDrinkLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextView *bioTextView;
@property (weak, nonatomic) IBOutlet UIImageView *pictureView;
@property UIImage *profileImageTaken;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIPickerView *genderPicker;
@property (weak, nonatomic) IBOutlet UILabel *genderLabel;
@property (weak, nonatomic) IBOutlet UIButton *editProfileButton;
@property (strong, nonatomic) UIButton *addPhotos;
@property NSArray *genderArray;
@property NSArray *interestedArray;
@property NSString *genderString;
@property NSString *interestedString;
@property NSArray *genderAttStringArray;
@property NSMutableArray *imagesArray;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property NSArray *interestedAttStringArray;
@property (weak, nonatomic) IBOutlet UIButton *doneButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *cancelButtonOutlet;
@property BOOL profilePic;


@end

@implementation EditProfileViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setStyle];

    self.scrollView.delegate = self;
    self.bioTextView.delegate = self;


    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];


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

    [self setFields];
}


- (void)setFields
{
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];

    self.nameTextField.text = [[PFUser currentUser]objectForKey:@"name"];

    if ([[PFUser currentUser]objectForKey: @"bio"])
    {
        self.bioTextView.text = [[PFUser currentUser]objectForKey:@"bio"];
    }
    else
    {
        self.bioTextView.text = @"";
    }

    NSInteger age = [[[PFUser currentUser]objectForKey: @"age"] integerValue];
    if (age > 1) {
        self.ageLabel.text = [NSString stringWithFormat: @"%@",[[PFUser currentUser]objectForKey: @"age"]];
    }
    else {
        self.ageLabel.text = nil;
    }
    if ([[PFUser currentUser]objectForKey: @"favoriteDrink"]) {
        self.favoriteDrinkLabel.text = [[PFUser currentUser]objectForKey: @"favoriteDrink"];
    }

    else {
        self.favoriteDrinkLabel.text = nil;
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
    [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, attrString.length)];
    self.genderLabel.attributedText = attrString;


    self.imagesArray = [NSMutableArray new];
    NSArray *filesArray = [[PFUser currentUser] objectForKey:@"imagesArray"];
        if (filesArray) {
            NSInteger counter = 0;
            for (PFFile *imageFile in filesArray) {
                counter += 1;
                    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
                     {
                         UIImage *image = [UIImage imageWithData:data];
                         [self.imagesArray addObject:image];

                         if (counter == filesArray.count) {
                             [self.collectionView reloadData];
                             [self createAddPhotosButton];
                             NSLog(@"Number of images: %lu", (unsigned long)self.imagesArray.count);

                             self.activityIndicator.hidden = YES;
                             [self.activityIndicator stopAnimating];
                         }
                    }];
                }
            }
        else {

            [self.collectionView reloadData];
            [self createAddPhotosButton];
        }

    PFFile *profileFile = [[PFUser currentUser] objectForKey:@"picture"];
    if (profileFile) {
        [profileFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
         {
             self.pictureView.image = [UIImage imageWithData:data];
         }];
    }
    else
    {
        self.pictureView.image = [UIImage imageNamed:@"profile-placeholder"];
    }
}

- (void)createImage:(BOOL) isProfilePic
{
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];

        CGSize scale = CGSizeMake(150, 150);
        UIGraphicsBeginImageContextWithOptions(scale, NO, 0.0);
        [self.profileImageTaken drawInRect:CGRectMake(0, 0, scale.width, scale.height)];
        UIImage * resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

    // Save PFFile
    if (isProfilePic) {
        NSData *imageData = UIImagePNGRepresentation(resizedImage);
        PFFile *imageFile = [PFFile fileWithData:imageData];

        [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [[PFUser currentUser] setObject:imageFile forKey:@"picture"];
                [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!error) {
                        NSLog(@"Should run when user has successfully uploaded a profile pic");
                        self.doneButtonOutlet.enabled = YES;
                        self.pictureView.image = resizedImage;
                        self.activityIndicator.hidden = YES;
                        [self.activityIndicator stopAnimating];
                    }
                    else {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to upload image" message:@"Please try again or select a new image" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        [alert show];
                    }
                }];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to upload image" message:@"Please try again or select a new image" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                }
        }];
    }

    else {
            [self.imagesArray addObject:resizedImage];
            NSLog(@"Images array count: %lu", (unsigned long)self.imagesArray.count);
            NSMutableArray *tempArray = [NSMutableArray new];
            NSInteger counter = 0;
            for (UIImage *image in self.imagesArray) {
                    counter += 1;
                    NSData *imageData = UIImagePNGRepresentation(image);
                    PFFile *imageFile = [PFFile fileWithData:imageData];
                        [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            if (error) {
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to upload image" message:@"Please try again or select a new image" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                [alert show];
                            }
                            else {
                                NSLog(@"Image was successfully uploaded");
                                [tempArray addObject:imageFile];

                                    if (counter == self.imagesArray.count) {
                                            NSLog(@"%ld should equal %lu", (long)counter, (unsigned long)self.imagesArray.count);
                                            [[PFUser currentUser] setObject:tempArray forKey:@"imagesArray"];
                                            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                    if (!error) {
                                        NSLog(@"Images array was successfully saved");
                                        self.doneButtonOutlet.enabled = YES;
                                        [self.collectionView reloadData];
                                        [self createAddPhotosButton];
                                    }
                                    else {
                                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to upload image" message:@"Please try again or select a new image" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                        [alert show];
                                        }
                                    }];
                                }
                            }
                        }];
                }
        }
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
         self.doneButtonOutlet.enabled = NO;
         [self createImage:self.profilePic];
     }];
}


#pragma mark - IBAction Button Pressed Methods
- (IBAction)onEditButtonPressed:(id)sender
{
    self.profilePic = YES;
    [self presentViewController:self.cameraController animated:NO completion:^{}];
}

-(void)createAddPhotosButton
{
    [self.addPhotos removeFromSuperview];

    if (self.imagesArray.count < 5) {
        NSLog(@"I ran");

    NSInteger numberOfPhotosInCollectionView = self.imagesArray.count;
    CGFloat imagewidth = 64.0;
    CGFloat horizontalOffset = imagewidth * numberOfPhotosInCollectionView;

    self.addPhotos = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.addPhotos addTarget:self
                       action:@selector(onAddPhotoButtonPressed:)
             forControlEvents:UIControlEventTouchUpInside];
    [self.addPhotos setTitle:@"Add Photos" forState:UIControlStateNormal];
    self.addPhotos.titleLabel.font = [UIFont systemFontOfSize:20.0];
    self.addPhotos.frame = CGRectMake(horizontalOffset, self.collectionView.frame.origin.y, self.collectionView.frame.size.width - horizontalOffset, self.collectionView.frame.size.height);

    if (self.imagesArray.count > 3) {
        [self.addPhotos setImage:[UIImage imageNamed:@"profile-placeholder"] forState:UIControlStateNormal];
        [self.addPhotos setBackgroundColor:[UIColor buttonColor]];
        NSLog(@"I ran");
    }
    else {
        [self.addPhotos setTitleColor:[UIColor buttonColor] forState:UIControlStateNormal];
        [self.addPhotos setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    }
    self.addPhotos.layer.borderWidth = 2.0f;
    self.addPhotos.layer.cornerRadius = 5.0f;
    self.addPhotos.layer.borderColor = [[UIColor buttonColor] CGColor];
    [self.view addSubview:self.addPhotos];
    }
    self.activityIndicator.hidden = YES;
    [self.activityIndicator stopAnimating];
}

-(void)onAddPhotoButtonPressed:(id)sender
{
    self.profilePic = NO;
    self.addPhotos.enabled = NO;
    [self presentViewController:self.cameraController animated:NO completion:^{}];
}

- (IBAction)onDoneButtonPressed:(id)sender
{
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];

    if (self.nameTextField.text != nil) {
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
    if ([self.genderString isEqualToString:@"man"]) {
        [[PFUser currentUser]setObject:@1 forKey:@"gender"];
        }
        else if ([self.genderString isEqualToString:@"woman"]) {
            [[PFUser currentUser]setObject:@0 forKey:@"gender"];
        }
        else if ([self.genderString isEqualToString:@"other"]) {
        [[PFUser currentUser]setObject:@2 forKey:@"gender"];
        }

    if ([self.interestedString isEqualToString:@"men"]) {
        [[PFUser currentUser]setObject:@0 forKey:@"sexualOrientation"];
        }
        else if ([self.interestedString isEqualToString:@"women"]) {
        [[PFUser currentUser]setObject:@1 forKey:@"sexualOrientation"];
        }
        else if ([self.interestedString isEqualToString:@"other"]){
        [[PFUser currentUser]setObject:@2 forKey:@"sexualOrientation"];
        }

        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

            self.activityIndicator.hidden = YES;
            [self.activityIndicator stopAnimating];
            [self.navigationController popToRootViewControllerAnimated:NO];
        }];
}


# pragma mark - CollectionView Methods

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.imagesArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CustomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.imageView.image = [self.imagesArray objectAtIndex:indexPath.row];
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
//{
//    return 0.0;
//}

#pragma mark - UITextView Delegate Methods
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{


    if([text isEqualToString:@"\b"]){
        return YES;
    }else if([[textView text] length] - range.length + text.length > 120){

        return NO;
    }

    return YES;
}


#pragma  mark - Pickerview methods
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
    pickerView.backgroundColor = [UIColor clearColor];
    if (component == 0)
    {
        return [self.genderAttStringArray objectAtIndex:row];
    }
    else{
        return [self.interestedAttStringArray objectAtIndex:row];
    }
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row   inComponent:(NSInteger)component
{
    switch (component)
    {
        case 0:
            switch(row)
        {
            case 0:
                self.genderString = [[self.genderArray objectAtIndex:0] lowercaseString];
                break;
            case 1:
                self.genderString = [[self.genderArray objectAtIndex:1] lowercaseString];
                break;
            case 2:
                self.genderString = [[self.genderArray objectAtIndex:2] lowercaseString];
                break;
                break;
        }
            break;
        case 1:
            switch(row)
        {
            case 0:
                self.interestedString = [[self.interestedArray objectAtIndex:0] lowercaseString];
                break;
            case 1:
                self.interestedString = [[self.interestedArray objectAtIndex:1] lowercaseString];
                break;
            case 2:
                self.interestedString = [[self.interestedArray objectAtIndex:2] lowercaseString];
                break;
        }
        default:
            break;
    }
    UIFont *boldFont = [UIFont boldSystemFontOfSize:18.0];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"I am a %@ interested in %@", self.genderString, self.interestedString]];
    [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, attrString.length)];
    [attrString addAttribute: NSFontAttributeName value: boldFont range: NSMakeRange(7, self.genderString.length)];
    [attrString addAttribute: NSFontAttributeName value: boldFont range: NSMakeRange(7 + self.genderString.length + 15,self.interestedString.length)];
    self.genderLabel.attributedText = attrString;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    pickerView.backgroundColor = [UIColor clearColor];
    if (component == 0)
    {
        return [self.genderAttStringArray objectAtIndex:row];
    }
    else{
        return [self.interestedAttStringArray objectAtIndex:row];
    }
}


#pragma mark - Set View Style

-(void)setStyle
{
    [self.doneButtonOutlet setTitleColor:[UIColor buttonColor] forState:UIControlStateSelected];
    [self.doneButtonOutlet setTitleColor:[UIColor buttonColor] forState:UIControlStateNormal];
    [self.doneButtonOutlet setTitleColor:[UIColor buttonColor] forState:UIControlStateSelected];
    [self.cancelButtonOutlet setTitleColor:[UIColor buttonColor] forState:UIControlStateSelected];
    [self.cancelButtonOutlet setTitleColor:[UIColor buttonColor] forState:UIControlStateNormal];
    [self.cancelButtonOutlet setTitleColor:[UIColor buttonColor] forState:UIControlStateSelected];

    self.activityIndicator.hidden = YES;
    self.scrollView.alwaysBounceVertical = YES;

    NSString *Man = @"Man";
    NSAttributedString *manString = [[NSAttributedString alloc] initWithString:Man attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    NSString *Woman = @"Woman";
    NSAttributedString *womanString = [[NSAttributedString alloc] initWithString:Woman attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    NSString *Other = @"Other";
    NSAttributedString *otherString = [[NSAttributedString alloc] initWithString:Other attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    NSString *Men = @"Men";
    NSAttributedString *menString = [[NSAttributedString alloc] initWithString:Men attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    NSString *Women = @"Women";
    NSAttributedString *womenString = [[NSAttributedString alloc] initWithString:Women attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];

    self.genderAttStringArray = [[NSArray alloc] initWithObjects:womanString, manString, otherString, nil];
    self.interestedAttStringArray = [[NSArray alloc] initWithObjects:womenString, menString, otherString, nil];
    self.genderArray = [[NSArray alloc] initWithObjects:@"Woman", @"Man", @"Other", nil];
    self.interestedArray = [[NSArray alloc] initWithObjects:@"women", @"men", @"other", nil];

    self.view.backgroundColor = [UIColor blackColor];

    self.nameTextField.clearButtonMode = UITextFieldViewModeAlways;
    self.ageLabel.clearButtonMode = UITextFieldViewModeAlways;
    self.favoriteDrinkLabel.clearButtonMode = UITextFieldViewModeAlways;

    self.nameTextField.textColor = [UIColor navBarColor];
    self.ageLabel.textColor = [UIColor navBarColor];
    self.favoriteDrinkLabel.textColor = [UIColor navBarColor];
    self.bioTextView.backgroundColor = [UIColor whiteColor];
    self.bioTextView.textColor = [UIColor navBarColor];

    self.collectionView.backgroundColor = [UIColor clearColor];
}

-(void)dismissKeyboard
{
    [self.view endEditing:YES];
}



@end
