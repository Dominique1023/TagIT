//
//  LogInViewController.m
//  TagIt
//
//  Created by Steven Sickler on 8/25/14.
//  Copyright (c) 2014 MobileMakers. All rights reserved.
//

#import "LogInViewController.h"
#import "SendViewController.h"

@interface LogInViewController () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *licensePlate;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UILabel *logInLabel;
@property (weak, nonatomic) IBOutlet UIButton *createAccount;
@property (weak, nonatomic) IBOutlet UIButton *logIn;
@property  PFUser *user;

@end

@implementation LogInViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

  // [self.licensePlate setAutocorrectionType:UITextAutocorrectionTypeNo];
    self.createAccount.hidden = YES;
    self.emailField.hidden = YES;
    
    [self.passwordField setSecureTextEntry:YES];
    [self.passwordField setAutocorrectionType:UITextAutocorrectionTypeNo];

}

- (IBAction)onSignUpButtonPressed:(UIButton *)sender
{
    if ([sender.titleLabel.text isEqualToString:@"Sign-Up"]) {

        [sender setTitle:@"Cancel" forState:UIControlStateNormal];

        [UIView animateWithDuration:1.2 animations:^{
            self.createAccount.hidden = NO;
            self.logIn.hidden = YES;
            self.logInLabel.transform = CGAffineTransformMakeTranslation(0, -105);
            self.logInLabel.transform = CGAffineTransformMakeTranslation(0, -220);
            self.emailField.hidden = NO;
            self.emailField.alpha = 1;
            self.emailField.text = @"";
            self.licensePlate.text = @"";
            self.passwordField.text = @"";
            sender.enabled = NO;
        } completion:^(BOOL finished) {
            sender.enabled = YES;
        }];

    } else {

        [sender setTitle:@"Sign-Up" forState:UIControlStateNormal];

        [UIView animateWithDuration:1.2 animations:^{
            self.logInLabel.transform = CGAffineTransformMakeTranslation(0, -105);
            self.logInLabel.transform = CGAffineTransformMakeTranslation(0, 5);
            self.emailField.alpha = 0;
            self.createAccount.hidden = YES;
            self.logIn.hidden = NO;
            sender.enabled = NO;
            self.licensePlate.text = @"";
            self.passwordField.text = @"";
        } completion:^(BOOL finished) {
            sender.enabled = YES;
            self.emailField.hidden = YES;
        }];
    }

}

- (IBAction)onLogInTapped:(UIButton *)sender
{
        NSString  *username = self.licensePlate.text;
        NSString *password = self.passwordField.text;

        [PFUser logInWithUsernameInBackground:username password:password
                                        block:^(PFUser *user, NSError *error) {
                                            if (user) {
                                                NSLog(@"User logged in");
                                                [self performSegueWithIdentifier:@"initialSegue" sender:self];
                                            } else {
                                                NSLog(@"User can not log in");

                                                UIAlertView *signupError = [[UIAlertView alloc] initWithTitle:@"Opps!"
                                                                                                      message:[NSString stringWithFormat:@"Invalid Plate &/or Password"]
                                                                                                     delegate:self cancelButtonTitle:@"Retry"
                                                                                            otherButtonTitles:nil, nil];
                                                [signupError show];

                                                self.licensePlate.text = @"";
                                                self.passwordField.text = @"";

                                            }
                                        }];
}

- (IBAction)onCreateNewAccount:(UIButton *)sender
{
        self.user = [PFUser user];
        self.user.username = self.licensePlate.text;
        self.user.password = self.passwordField.text;
        self.user.email = self.emailField.text;

        [self.user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {

               // [self performSegueWithIdentifier:@"initialSegue" sender:self];
            }else {
                NSString *errorString = [[error userInfo] objectForKey:@"error"];
                UIAlertView *signupError = [[UIAlertView alloc] initWithTitle:@"Opps!"
                                            message:[NSString stringWithFormat:@"Looks like we have a small issue: %@", errorString]
                                            delegate:self cancelButtonTitle:@"Continue"
                                            otherButtonTitles:nil, nil];

                [signupError show];
             }
        }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {



}

@end
