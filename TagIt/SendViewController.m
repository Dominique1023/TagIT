//
//  SendViewController.m
//  TagIt
//
//  Created by Alex Hudson on 8/26/14.
//  Copyright (c) 2014 MobileMakers. All rights reserved.
//

#import "SendViewController.h"

@interface SendViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIActionSheetDelegate>
{
    UIActionSheet * actionSheet;
    UIImagePickerController * imagePicker;
}
@property (strong, nonatomic) IBOutlet UIImageView *photoImageView;
@property (strong, nonatomic) IBOutlet UITextView *typedMessage;
@property (strong, nonatomic) IBOutlet UITextField *receivingLicensePlate;
@property (weak, nonatomic) IBOutlet UIButton *clearPhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *addPhotoButton;

@end

@implementation SendViewController

- (void)viewDidLoad{
    [super viewDidLoad];

    self.clearPhotoButton.hidden = YES;

    //checks to see if device has camera
    [self whatSourceType];

    //turns off auto correct for license plate field
    [self.receivingLicensePlate setAutocorrectionType:UITextAutocorrectionTypeNo];

    //self.receivingLicensePlate.placeholder.

    UIColor *color = [UIColor grayColor];
    self.receivingLicensePlate.attributedPlaceholder =
    [[NSAttributedString alloc]
     initWithString:@"Driver's License Plate"
     attributes:@{NSForegroundColorAttributeName:color}];

    self.typedMessage.backgroundColor = [UIColor clearColor];
  //  self.typedMessage.textColor = [UIColor lightGrayColor];
    //self.typedMessage.

    // hides keyboard when user touches outside of text fields
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(textFieldShouldReturn:)];
    [self.view addGestureRecognizer:tap];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.typedMessage resignFirstResponder];
    [self.receivingLicensePlate resignFirstResponder];

    return YES;
}

- (IBAction)onClearPhotoButtonPressed:(id)sender {
    self.photoImageView.image = nil;
    self.addPhotoButton.hidden = NO;
    self.clearPhotoButton.hidden = YES;
     self.photoImageView.layer.borderWidth=0.0;
}

//uploads message, user and photo up to parse
- (IBAction)sendOnVentButtonPressed:(id)sender{
    PFObject * message = [PFObject objectWithClassName:@"Message"];
    message[@"text"] = self.typedMessage.text;
    message[@"from"] = [PFUser currentUser];
    message[@"to"] = self.receivingLicensePlate.text;

    UIImage * image = self.photoImageView.image;
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    PFFile *file = [PFFile fileWithData:imageData];

    if ([self.receivingLicensePlate.text isEqualToString:@""]) {
      UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error!" message:@"Enter License Plate" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
      [alertView show];
      
      return;
    }

    if ([self.typedMessage.text isEqualToString:@""] || [self.photoImageView.image isEqual:nil]) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Enter a Message or Picture" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];

        return;
    }

    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        message[@"photo"] = file;

        [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
            if (error){
                NSLog(@"%@", [error userInfo]);
            }
        }];
    }];

    [self performSegueWithIdentifier:@"ventPressed" sender:self];
}

#pragma mark UIIMAGEPICKER DELEGEATE METHODS
-(void)whatSourceType{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Device Has No Camera" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];

        [alertView show];
    }else{
        return;
    }
}

- (IBAction)onAddPhotoButtonPressed:(id)sender{
    [self showPhotoMenu];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.photoImageView.image = chosenImage;

    self.clearPhotoButton.hidden = NO;
    self.addPhotoButton.hidden = YES;

    self.photoImageView.layer.cornerRadius=8;
    self.photoImageView.layer.borderWidth=2.0;
    self.photoImageView.layer.masksToBounds = YES;

    self.photoImageView.layer.borderColor=[[UIColor whiteColor] CGColor];
  //  self.photoImageView.layer.borderColor=[[UIColor colorWithRed:250.f/255.f green:80.f/255.f blue:84.f/255.f alpha:1.f] CGColor];
   // self.photoImageView.layer.borderColor=[UIColor colorWithRed:250 green:80 blue:84 alpha:100];

    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UIACTIONSHEET DELEGATE
-(void)actionSheet:(UIActionSheet *)theActionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 0) {
        [self takePhoto];
    }else if (buttonIndex ==1) {
        [self choosePhotoFromLibrary];
    }
    actionSheet = nil;
}

-(void)takePhoto{
    UIImagePickerController *picker = [UIImagePickerController new];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:nil];

}

-(void)choosePhotoFromLibrary{
    imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    [self presentViewController:imagePicker animated:YES completion:nil];
    self.clearPhotoButton.hidden = NO;
    self.addPhotoButton.hidden = YES;
}

-(void)showPhotoMenu{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){

        //UIActionSheet *actionSheet = [[UIActionSheet alloc]

        actionSheet = [[UIActionSheet alloc]
                       initWithTitle:nil
                       delegate:self
                       cancelButtonTitle:@"Cancel"
                       destructiveButtonTitle:nil
                       otherButtonTitles:@"Take Photo", @"Choose From Library", nil];

        [actionSheet showInView:self.view];

    }else {
        [self choosePhotoFromLibrary];
    }
}

@end





















