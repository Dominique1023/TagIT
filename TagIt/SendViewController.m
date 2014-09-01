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
@property NSData *data;

@end

@implementation SendViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self whatSourceType];
    [self.receivingLicensePlate setAutocorrectionType:UITextAutocorrectionTypeNo];
    self.typedMessage.backgroundColor = [UIColor clearColor];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(textFieldShouldReturn:)];
    [self.view addGestureRecognizer:tap];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.typedMessage resignFirstResponder];
    [self.receivingLicensePlate resignFirstResponder];

    return YES;
}

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

    //can't be nested because if that user did put a license plate than nothing inside that loop will run

    if ([self.typedMessage.text isEqualToString:@""] || [self.imageView.image isEqual:nil]) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Enter a Message or Picture" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];

        return;
    }

    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        message[@"photo"] = file;
        [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

            if (error) {
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

- (IBAction)onTakePhotoButtonPressed:(id)sender{

    [self showPhotoMenu];
//    UIImagePickerController *picker = [UIImagePickerController new];
//    picker.delegate = self;
//    picker.allowsEditing = YES;
//    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
//    //picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:picker.sourceType];
//
//    [self presentViewController:picker animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = chosenImage;

    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)theActionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0) {
        [self takePhoto];
    }else if (buttonIndex ==1) {
        [self choosePhotoFromLibrary];
    }
    actionSheet = nil;
}

-(void)takePhoto
{
    UIImagePickerController *picker = [UIImagePickerController new];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:nil];
}

-(void)choosePhotoFromLibrary
{
    imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    [self presentViewController:imagePicker animated:YES completion:nil];
}
-(void)showPhotoMenu
{
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





















