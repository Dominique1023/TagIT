//
//  LogInViewController.m
//  TagIt
//
//  Created by Steven Sickler on 8/25/14.
//  Copyright (c) 2014 MobileMakers. All rights reserved.
//

#import "LogInViewController.h"
#import "SendViewController.h"

@interface LogInViewController () <UIAlertViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *licensePlate;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UILabel *logInLabel;
@property (weak, nonatomic) IBOutlet UIButton *createAccount;
@property (weak, nonatomic) IBOutlet UIButton *logIn;
@property (weak, nonatomic) IBOutlet UIView *myView;
@property UIAlertView *forgotPasswordAlertView;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButton;

@end

@implementation LogInViewController

- (void)viewDidLoad{
    [super viewDidLoad];

    [self.licensePlate setAutocorrectionType:UITextAutocorrectionTypeNo];
    self.createAccount.hidden = YES;
    self.emailField.hidden = YES;
    
    [self.passwordField setSecureTextEntry:YES];
    [self.passwordField setAutocorrectionType:UITextAutocorrectionTypeNo];

    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note){
         self.myView.center = CGPointMake(self.view.center.x, self.view.center.y - 15);
     }];

    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        self.myView.center = CGPointMake(self.view.center.x, self.view.center.y + 15);
    }];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(textFieldShouldReturn:)];
    [self.view addGestureRecognizer:tap];
}



-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];

    if (![PFUser currentUser]){
        NSLog(@"User needs to sign in");
    }else{
        NSLog(@"Automatically Signed User In");
        [self performSegueWithIdentifier:@"initialSegue" sender:self];
    }
}

#pragma mark FORGOT PASSWORD

- (IBAction)onForgotPasswordButtonPressed:(id)sender {
    self.forgotPasswordAlertView = [[UIAlertView alloc]initWithTitle:@"Enter Email Address" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Done", nil];

    self.forgotPasswordAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *alertTextField = [self.forgotPasswordAlertView textFieldAtIndex:0];
    alertTextField.keyboardType = UIKeyboardTypeDefault;

    [self.forgotPasswordAlertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex != self.forgotPasswordAlertView.cancelButtonIndex) {
        NSString *email = [self.forgotPasswordAlertView textFieldAtIndex:0].text;
        [PFUser requestPasswordResetForEmailInBackground:email block:^(BOOL succeeded, NSError *error) {
            if (error) {
                self.forgotPasswordAlertView = [[UIAlertView alloc]initWithTitle:@"Invalid Email" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];

                [self.forgotPasswordAlertView show];
            }

            NSLog(@"Changed email address with: %@", email);
        }];
    }
}

#pragma mark LOGING AND SIGNING UP

- (IBAction)onSignUpButtonPressed:(UIButton *)sender{
    if ([sender.titleLabel.text isEqualToString:@"Sign-Up"]){

        [sender setTitle:@"Cancel" forState:UIControlStateNormal];
        [sender setTitleColor:[UIColor redColor] forState:UIControlStateNormal];

        [UIView animateWithDuration:1.2 animations:^{
            self.logIn.hidden = YES;
            self.forgotPasswordButton.hidden = YES;

            self.logInLabel.transform = CGAffineTransformMakeTranslation(0, -90);
            self.logInLabel.transform = CGAffineTransformMakeTranslation(0, -185);

            self.emailField.transform = CGAffineTransformMakeTranslation(0, -60);
            self.emailField.transform = CGAffineTransformMakeTranslation(0, -120);

            self.licensePlate.transform = CGAffineTransformMakeTranslation(0, -60);
            self.licensePlate.transform = CGAffineTransformMakeTranslation(0, -120);

            self.passwordField.transform = CGAffineTransformMakeTranslation(0, -60);
            self.passwordField.transform = CGAffineTransformMakeTranslation(0, -120);

            self.emailField.hidden = NO;
            self.emailField.alpha = 1;
            self.emailField.text = @"";
            self.licensePlate.text = @"";
            self.passwordField.text = @"";
            sender.enabled = NO;

        }completion:^(BOOL finished){
            sender.enabled = YES;
            self.createAccount.hidden = NO;
        }];
    }else{
        [sender setTitle:@"Sign-Up" forState:UIControlStateNormal];
        [sender setTitleColor:[UIColor blueColor] forState:UIControlStateNormal]; 

        [UIView animateWithDuration:1.2 animations:^{
            self.logInLabel.transform = CGAffineTransformMakeTranslation(0, -90);
            self.logInLabel.transform = CGAffineTransformMakeTranslation(0, 5);

            self.emailField.transform = CGAffineTransformMakeTranslation(0, -60);
            self.emailField.transform = CGAffineTransformMakeTranslation(0, 5);

            self.licensePlate.transform = CGAffineTransformMakeTranslation(0, -60);
            self.licensePlate.transform = CGAffineTransformMakeTranslation(0, 5);

            self.passwordField.transform = CGAffineTransformMakeTranslation(0, -60);
            self.passwordField.transform = CGAffineTransformMakeTranslation(0, 5);


            self.emailField.alpha = 0;
            self.createAccount.hidden = YES;
            self.logIn.hidden = NO;
            self.forgotPasswordButton.hidden = NO;
            sender.enabled = NO;
            self.licensePlate.text = @"";
            self.passwordField.text = @"";

        }completion:^(BOOL finished){
            sender.enabled = YES;
            self.emailField.hidden = YES;
        }];
    }
}

- (IBAction)onLogInTapped:(UIButton *)sender{
    NSString  *username = self.licensePlate.text;
    NSString *password = self.passwordField.text;

    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
        if (user) {
            NSLog(@"User logged in");
            [self performSegueWithIdentifier:@"initialSegue" sender:self];
        }else{
            NSLog(@"User can not log in");

            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Opps!" message:[NSString stringWithFormat:@"Invalid Plate &/or Password"] delegate:self cancelButtonTitle:@"Retry" otherButtonTitles:nil, nil];
            [alertView show];

            self.licensePlate.text = @"";
            self.passwordField.text = @"";
        }
    }];
}

- (IBAction)onCreateNewAccount:(UIButton *)sender{
    PFUser *user = [PFUser user];
    user.username = self.licensePlate.text;
    user.password = self.passwordField.text;
    user.email = self.emailField.text;

    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if (!error){
            [self performSegueWithIdentifier:@"initialSegue" sender:self];
        }else{
            NSString *errorString = [[error userInfo] objectForKey:@"error"];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Opps!" message:[NSString stringWithFormat:@"Looks like we have a small issue: %@", errorString] delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil, nil];

            [alertView show];
         }
    }];
}

#pragma mark TEXTFEILD DELEGATES 

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.emailField resignFirstResponder];
    [self.licensePlate resignFirstResponder];
    [self.passwordField resignFirstResponder];

    return YES;
}


@end
