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
@property NSString *usersObjectId;

@end

@implementation SendViewController

- (void)viewDidLoad{
    [super viewDidLoad];

    //Turining all license plate to caps. NOTE: this ONLY works using the device/simulators keyboard!!!!
    //Shows the characters as all caps when the user is typing it
    self.receivingLicensePlate.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    //changes all the characters to to caps
    [self.receivingLicensePlate.text uppercaseString];


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
    self.photoImageView.layer.borderWidth = 0.0;
}

//uploads message, user and photo up to parse
- (IBAction)sendOnVentButtonPressed:(id)sender{


//    NSString *lastCharacter = [self.receivingLicensePlate.text substringFromIndex: self.receivingLicensePlate.text.length -1 ];
//
//    if ([lastCharacter  isEqual: @" "]) {
//        NSLog(@"Testing Empty String");
//    }



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

    UIImage *image = self.photoImageView.image;
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    PFFile *file = [PFFile fileWithData:imageData];

    //Quering so Push Notification sends to only the receiving user
    PFQuery *usersQuery = [PFUser query];
    [usersQuery whereKeyExists:@"username"];

    [usersQuery findObjectsInBackgroundWithBlock:^(NSArray *comments, NSError *error) {
        if (error) {
            NSLog(@"error");
        }else{
            for (PFObject *user in comments) {

                //if the receivingLicensePlate is not a user than do nothing, else grab that licensePlate's objectID
                NSString *username = user[@"username"];

                if (![username isEqualToString:self.receivingLicensePlate.text]) {
                    NSLog(@"Not the receiving user");

                    return;
                }else{
                    self.usersObjectId = user.objectId;

                    return; 
                }
            }
        }

    }];


    PFObject *message = [PFObject objectWithClassName:@"Message"];
    message[@"text"] = self.typedMessage.text;
    message[@"from"] = [PFUser currentUser];
    message[@"to"] = self.receivingLicensePlate.text;
    message[@"senderId"] =[[PFUser currentUser] objectId];
    message[@"senderName"] = [[PFUser currentUser] username];

    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        message[@"photo"] = file;

        [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
            if (error){
                NSLog(@"%@", [error userInfo]);
            }else {

                // Send Push Notification to recipient
                PFQuery *pushQuery = [PFInstallation query];
                [pushQuery whereKey:@"installationUser" equalTo:[[PFUser currentUser] objectId]];


                //Checks if that objectID is nil, if it is than just update the senders table, if its not nil than send a push
                if (self.usersObjectId != nil) {
                    PFQuery *pushQueryy = [PFInstallation query];
                    [pushQueryy whereKey:@"installationUser" equalTo:self.usersObjectId];

//                    PFPush *push = [[PFPush alloc] init];
//                    [push setQuery:pushQueryy];
//                    [push setMessage:message[@"text"]];
//                    [push sendPushInBackground];


                    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                          self.typedMessage.text, @"alert",
                                          @"Increment", @"badge",
                                          @"car-horn.wav", @"sound",
                                          nil];
                    PFPush *push = [[PFPush alloc] init];
                    [push setQuery:pushQueryy];
                    [push setData:data];
                    [push sendPushInBackground];

                }


                //Sends a in-code notification to update the sent table view in SentReceiveViewController
                [[NSNotificationCenter defaultCenter] postNotificationName:@"onSendButtonPressed" object:self.typedMessage.text];

            }
        }];

    }];

    [self performSegueWithIdentifier:@"ventPressed" sender:self];
}


#pragma mark UIACTIONSHEET AND UIIMAGEPICKERCONTROLLER DELEGATE METHODS
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
    //self.photoImageView.layer.borderColor=[[UIColor colorWithRed:250.f/255.f green:80.f/255.f blue:84.f/255.f alpha:1.f] CGColor];
    //self.photoImageView.layer.borderColor=[UIColor colorWithRed:250 green:80 blue:84 alpha:100];

    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

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
        actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose From Library", nil];

        [actionSheet showInView:self.view];
    }else {
        [self choosePhotoFromLibrary];
    }
}

@end





















