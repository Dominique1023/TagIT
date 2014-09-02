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
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
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
    self.typedMessage.backgroundColor = [UIColor clearColor];

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
    self.imageView.image = nil;
    self.addPhotoButton.hidden = NO;
    self.clearPhotoButton.hidden = YES;
}

//uploads message, user and photo up to parse
- (IBAction)sendOnVentButtonPressed:(id)sender{
    PFObject * message = [PFObject objectWithClassName:@"Message"];
    message[@"text"] = self.typedMessage.text;
    message[@"from"] = [PFUser currentUser];
    message[@"to"] = self.receivingLicensePlate.text;

    UIImage * image = self.imageView.image;
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    PFFile *file = [PFFile fileWithData:imageData];

    if ([self.receivingLicensePlate.text isEqualToString:@""]) {
      UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error!" message:@"Enter License Plate" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
      [alertView show];
      
      return;
    }

    if ([self.typedMessage.text isEqualToString:@""] || [self.imageView.image isEqual:nil]) {
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
    self.clearPhotoButton.hidden = NO;
    self.addPhotoButton.hidden = YES;
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = chosenImage;

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





















