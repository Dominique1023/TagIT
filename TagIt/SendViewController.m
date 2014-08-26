//
//  SendViewController.m
//  TagIt
//
//  Created by Alex Hudson on 8/26/14.
//  Copyright (c) 2014 MobileMakers. All rights reserved.
//

#import "SendViewController.h"

@interface SendViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UITextField *typedMessage;
@property (strong, nonatomic) IBOutlet UITextField *receivingUser;
@property NSData *data;

@end

@implementation SendViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self whatSourceType];
    [self.receivingUser setAutocorrectionType:UITextAutocorrectionTypeNo];

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

- (IBAction)onTakePhotoButtonPressed:(id)sender {
    UIImagePickerController *picker = [UIImagePickerController new];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;

    [self presentViewController:picker animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)sendOnVentButtonPressed:(id)sender {

    PFObject * message = [PFObject objectWithClassName:@"Message"];
    message[@"text"] = self.typedMessage.text;
    message[@"from"] = [PFUser currentUser];
    message[@"to"] = self.receivingUser.text;


    UIImage * image = self.imageView.image;
    NSData *imageData = UIImageJPEGRepresentation(image, 0.06);

    PFFile *file = [PFFile fileWithData:imageData];

    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        message[@"photo"] = file;
        [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                NSLog(@"%@", [error userInfo]);
            }
        }];
    }];
}

@end
