//
//  SettingsViewController.m
//  TagIt
//
//  Created by Alex Hudson, Dominique Vasquez, Steven Sickler on 8/27/14.
//  Copyright (c) 2014 MobileMakers. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController () <UITextFieldDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property UIAlertView *unblockAlertView;
@property UIAlertView *changeEmailAlertView;
@end

@implementation SettingsViewController

- (void)viewDidLoad{
    [super viewDidLoad];

    [self showUserLoggedInLabel];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(textFieldShouldReturn:)];
    [self.view addGestureRecognizer:tap];
}

- (IBAction)logOutOnButtonPressed:(id)sen{
    [PFUser logOut];
}

- (IBAction)onUnblockAllUsersButtonPressed:(id)sender{

    //confirming from the user that they want to remove all blocked users
    self.unblockAlertView = [[UIAlertView alloc] initWithTitle:@"Warning!" message:@"This will unblock all license plates" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue", nil];

    [self.unblockAlertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //If its the unblock alertview being shown
    if (alertView == self.unblockAlertView) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            PFUser *user = [PFUser currentUser];

            //creating a new NSMutableArray and setting it the currentUsers blockedUsers array on parse
            NSMutableArray * unblockUsersArray = user[@"blockedUsers"];

            //if they haven't blocked anyone than init a new NSMutableArray, other wise remove all objects
            if (unblockUsersArray == nil){
                unblockUsersArray = [NSMutableArray new];
            }else{
                [unblockUsersArray removeAllObjects];
            }

            //updating the array on parse
            user[@"blockedUsers"] = unblockUsersArray;

            //save the empty array on parse, removing all the blocked users
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    NSLog(@"Error");
                }else {
                    NSLog(@"successfully unblocked all users");
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"Unblock and reload" object:nil];
                }
            }];
        }
        //or if the change email alert view is being shown
    }else if(alertView == self.changeEmailAlertView) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            PFUser *user = [PFUser currentUser];

            NSString *newEmail = [alertView textFieldAtIndex:0].text;
            NSLog(@"%@", newEmail);

            if (![newEmail  isEqual: @""]){

                //prevents the user from accidentally setting a blank email
                if ([newEmail rangeOfString:@"@"].location == NSNotFound){
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Invalid Email" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];

                    [alertView show];
                }else{
                    [user setEmail:newEmail];
                    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        NSLog(@"email changed");
                        NSLog(@"%@", newEmail);
                    }];
                }
            }else{
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Email Field Empty" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];

                [alertView show];
            }
        }
    }
}

-(void)showUserLoggedInLabel{
    PFUser *user = [PFUser currentUser];
    self.userLabel.text = user.username;
}

- (IBAction)onChangePasswordButtonChanged:(id)sender{
    PFUser *user = [PFUser currentUser];

    [PFUser requestPasswordResetForEmailInBackground:user.email block:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"%@", error.userInfo);
        }else{
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"An e-mail will be sent shortly" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];

            [alertView show];
        }
    }];
}

- (IBAction)onChangeEmailButtonPressed:(id)sender{
    self.changeEmailAlertView = [[UIAlertView alloc]initWithTitle:@"Email Change" message:@"Enter new email address" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];

    self.changeEmailAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *changeEmailTextField = [self.changeEmailAlertView textFieldAtIndex:0];
    changeEmailTextField.keyboardType = UIKeyboardTypeDefault;

    [self.changeEmailAlertView show];
}

@end
