//
//  SettingsViewController.m
//  TagIt
//
//  Created by Steven Sickler on 8/27/14.
//  Copyright (c) 2014 MobileMakers. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController () <UITextFieldDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UITextField *changeEmailTextField;

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
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning!" message:@"This will unblock all license plates" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue", nil];

    [alertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex != alertView.cancelButtonIndex) {
        PFUser *user = [PFUser currentUser];

        //creating a new NSMutableArray and setting it the currentUsers blockedUsers array on parse
        NSMutableArray * unblockUsersArray = user[@"blockedUsers"];

        //if they haven't blocked anyone than init a new NSMutableArray, other wise remove all objects
        if (unblockUsersArray == nil) {
            unblockUsersArray = [NSMutableArray new];
        }else {
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
            }
        }];
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

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    //[self.blockedUserTextField resignFirstResponder];
    [self.changeEmailTextField resignFirstResponder];
    
    return YES;
}

- (IBAction)onChangeEmailButtonPressed:(id)sender{
    PFUser *user = [PFUser currentUser];

    NSString *newEmail = self.changeEmailTextField.text;
    NSLog(@"%@", newEmail);

    [user setEmail:newEmail];
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"email changed");
        NSLog(@"%@", newEmail);
    }];

    self.changeEmailTextField.text = @"";
}

@end
