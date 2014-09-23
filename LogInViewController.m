//
//  LogInViewController.m
//  TagIt
//
//  Created by Alex Hudson, Dominique Vasquez, Steven Sickler on 8/25/14.
//  Copyright (c) 2014 RoadRage. All rights reserved.
//

#import "LogInViewController.h"
#import "SendViewController.h"

@interface LogInViewController () <UIAlertViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *licensePlateTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIImageView *roadRageLabel;
@property (weak, nonatomic) IBOutlet UIButton *createAccountButton;
@property (weak, nonatomic) IBOutlet UIButton *logInButton;
@property (weak, nonatomic) IBOutlet UIView *myView;
@property (weak, nonatomic) IBOutlet UILabel *forgotPasswordLabel;
@property (weak, nonatomic) IBOutlet UITextField *forgotPasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelResetPasswordButton;
@property UIAlertView *forgotPasswordAlertView;
@property BOOL isCancelShowing;

@end

@implementation LogInViewController

- (void)viewDidLoad{
    [super viewDidLoad];

    //because were changing one buttons image to cancel in a certain view, to keep track of which image is showing.
    self.isCancelShowing = NO;

    self.licensePlateTextField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    [self.licensePlateTextField.text uppercaseString];

    //Turning off autocorrect for license plate
    [self.licensePlateTextField setAutocorrectionType:UITextAutocorrectionTypeNo];

    self.createAccountButton.hidden = YES;
    self.emailTextField.hidden = YES;
    self.forgotPasswordLabel.hidden = YES;
    self.forgotPasswordTextField.hidden = YES;
    self.doneButton.hidden = YES;
    self.cancelResetPasswordButton.hidden = YES;

     //Turning off autocorrect for password and hiding letters
    [self.passwordField setSecureTextEntry:YES];
    [self.passwordField setAutocorrectionType:UITextAutocorrectionTypeNo];

    //Transitions myView when keyboard comes up and goes down
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note){
         self.myView.center = CGPointMake(self.view.center.x, self.view.center.y - 15);
     }];

    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        self.myView.center = CGPointMake(self.view.center.x, self.view.center.y + 15);
    }];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(textFieldShouldReturn:)];

    [self.view addGestureRecognizer:tap];
}

//Allows a user to remain logged in
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];

    self.isCancelShowing = NO;

    if (![PFUser currentUser]){
        NSLog(@"User needs to sign in");
    }else{
        NSLog(@"Automatically Signed User In");
        [self performSegueWithIdentifier:@"initialSegue" sender:self];
    }
}

#pragma mark LOG IN SIGN UP

//lets user sign up
- (IBAction)onSignUpButtonPressed:(UIButton *)sender{
    if (self.isCancelShowing == NO) {

        [self.signUpButton setBackgroundImage:[UIImage imageNamed:@"CancelButton"] forState:UIControlStateNormal];

        [UIView animateWithDuration:1.2 animations:^{
            self.logInButton.hidden = YES;

            self.roadRageLabel.transform = CGAffineTransformMakeTranslation(0, -90);
            self.roadRageLabel.transform = CGAffineTransformMakeTranslation(0, -185);

            self.emailTextField.transform = CGAffineTransformMakeTranslation(0, -60);
            self.emailTextField.transform = CGAffineTransformMakeTranslation(0, -120);

            self.licensePlateTextField.transform = CGAffineTransformMakeTranslation(0, -60);
            self.licensePlateTextField.transform = CGAffineTransformMakeTranslation(0, -120);

            self.passwordField.transform = CGAffineTransformMakeTranslation(0, -60);
            self.passwordField.transform = CGAffineTransformMakeTranslation(0, -120);

            self.emailTextField.hidden = NO;
            self.emailTextField.alpha = 1;
            self.emailTextField.text = @"";
            self.licensePlateTextField.text = @"";
            self.passwordField.text = @"";
            sender.enabled = NO;

        }completion:^(BOOL finished){
            sender.enabled = YES;
            self.createAccountButton.hidden = NO;
            self.isCancelShowing = YES;

        }];

    }else{
        [self.signUpButton setBackgroundImage:[UIImage imageNamed:@"SignUpButton"] forState:UIControlStateNormal];

        //Animations to move/hide labels and textfields instead of going to a new view controller for login and signup views
        [UIView animateWithDuration:1.2 animations:^{
            self.roadRageLabel.transform = CGAffineTransformMakeTranslation(0, -90);
            self.roadRageLabel.transform = CGAffineTransformMakeTranslation(0, 5);

            self.emailTextField.transform = CGAffineTransformMakeTranslation(0, -60);
            self.emailTextField.transform = CGAffineTransformMakeTranslation(0, 5);

            self.licensePlateTextField.transform = CGAffineTransformMakeTranslation(0, -60);
            self.licensePlateTextField.transform = CGAffineTransformMakeTranslation(0, 5);

            self.passwordField.transform = CGAffineTransformMakeTranslation(0, -60);
            self.passwordField.transform = CGAffineTransformMakeTranslation(0, 5);

            self.emailTextField.alpha = 0;
            self.createAccountButton.hidden = YES;
            self.logInButton.hidden = NO;
            self.licensePlateTextField.text = @"";
            self.passwordField.text = @"";
            sender.enabled = NO;

        }completion:^(BOOL finished){
            sender.enabled = YES;
            self.emailTextField.hidden = YES;
            self.isCancelShowing = NO;

        }];
    }
}

//Allows user to log in
- (IBAction)onLogInTapped:(UIButton *)sender{

    //trims the white space and/or - in license plates for uniform license plates
    self.licensePlateTextField.text = [self.licensePlateTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    self.licensePlateTextField.text = [self.licensePlateTextField.text stringByReplacingOccurrencesOfString:@"-" withString:@""];

    NSString  *username = self.licensePlateTextField.text;
    NSString *password = self.passwordField.text;

    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {

        if (error) {
            NSLog(@"%@", error);
            NSLog(@"User can not log in");

            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"The email or password you entered is incorrect." delegate:self cancelButtonTitle:@"Retry" otherButtonTitles:@"Forgot Password", nil];

            [alertView show];

            self.licensePlateTextField.text = @"";
            self.passwordField.text = @"";
        }else{
            if (user) {
                NSLog(@"User logged in");
                [self performSegueWithIdentifier:@"initialSegue" sender:self];
            }else{

            }
        }
    }];
}

//called when user touches "Forget Password", hides login buttons
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex != alertView.cancelButtonIndex) {
        self.forgotPasswordLabel.hidden = NO;
        self.forgotPasswordTextField.hidden = NO;
        self.roadRageLabel.hidden = YES;
        self.licensePlateTextField.hidden = YES;
        self.passwordField.hidden = YES;
        self.logInButton.hidden = YES;
        self.signUpButton.hidden = YES;
        self.doneButton.hidden = NO;
        self.cancelResetPasswordButton.hidden = NO;
    }
}

//when user touches cancel on forget password, returns to login view
- (IBAction)onCancelResetPasswordButtonPressed:(id)sender{
    self.forgotPasswordLabel.hidden = YES;
    self.forgotPasswordTextField.hidden = YES;
    self.roadRageLabel.hidden = NO;
    self.licensePlateTextField.hidden = NO;
    self.passwordField.hidden = NO;
    self.logInButton.hidden = NO;
    self.signUpButton.hidden = NO;
    self.doneButton.hidden = YES;
    self.cancelResetPasswordButton.hidden = YES;
}

//Sends email to user to request new password
- (IBAction)onDoneButtonPressed:(id)sender{
    NSString *forgotPasswordEmail = self.forgotPasswordTextField.text;

    [PFUser requestPasswordResetForEmailInBackground:forgotPasswordEmail block:^(BOOL succeeded, NSError *error) {

        if (error){
            UIAlertView *errorAlertView = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Invalid email address. \n Please try again" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];

            [errorAlertView show];

        }else{
            UIAlertView *confirmationAlertView = [[UIAlertView alloc]initWithTitle:@"Please check your email to complete password reset" message:nil delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
            [confirmationAlertView show];

            self.forgotPasswordTextField.text = @"";
            [self.forgotPasswordTextField resignFirstResponder];

            self.forgotPasswordLabel.hidden = YES;
            self.forgotPasswordTextField.hidden = YES;
            self.roadRageLabel.hidden = NO;
            self.licensePlateTextField.hidden = NO;
            self.passwordField.hidden = NO;
            self.logInButton.hidden = NO;
            self.signUpButton.hidden = NO;
            self.doneButton.hidden = YES;
        }
    }];
}

- (IBAction)onCreateNewAccount:(UIButton *)sender{

    //trims the white space and/or - in license plates for uniform license plates
    self.licensePlateTextField.text = [self.licensePlateTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    self.licensePlateTextField.text = [self.licensePlateTextField.text stringByReplacingOccurrencesOfString:@"-" withString:@""];

    //license plates are usernames
    PFUser *user = [PFUser user];
    user.username = self.licensePlateTextField.text;
    user.password = self.passwordField.text;
    user.email = self.emailTextField.text;

    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if (!error){
            [self performSegueWithIdentifier:@"initialSegue" sender:self];
        }else{
            NSString *errorString = [[error userInfo] objectForKey:@"error"];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:[NSString stringWithFormat:@"Looks like we have a small issue: %@", errorString] delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil, nil];

            [alertView show];
         }
    }];
}

#pragma mark TEXTFEILD DELEGATES
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.emailTextField resignFirstResponder];
    [self.licensePlateTextField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [self.forgotPasswordTextField resignFirstResponder];

    return YES;
}

@end
