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


    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning!" message:[NSString stringWithFormat:@"This will unblock all blocked license plates"] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue", nil];
    [alertView show];



}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex != alertView.cancelButtonIndex) {

        PFUser *user = [PFUser currentUser];

        NSMutableArray * unblockUsersArray = user[@"blockedUsers"];
        if (unblockUsersArray == nil) {
            unblockUsersArray = [NSMutableArray new];
        }else {
            [unblockUsersArray removeAllObjects];
        }
        user[@"blockedUsers"] = unblockUsersArray;

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
