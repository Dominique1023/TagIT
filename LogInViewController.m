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

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *licensePlateTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UILabel *roadRageLabel;
@property (weak, nonatomic) IBOutlet UIButton *createAccountButton;
@property (weak, nonatomic) IBOutlet UIButton *logInButton;
@property (weak, nonatomic) IBOutlet UIView *myView;
@property (weak, nonatomic) IBOutlet UILabel *forgotPasswordLabel;
@property (weak, nonatomic) IBOutlet UITextField *forgotPasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelResetPasswordButton;
@property UIAlertView *forgotPasswordAlertView;

@end

@implementation LogInViewController

- (void)viewDidLoad{
    [super viewDidLoad];


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
    if ([sender.titleLabel.text isEqualToString:@"Sign-Up"]){

        //moves everything up and changes "signup" to "cancel"
        [sender setTitle:@"Cancel" forState:UIControlStateNormal];
        [sender setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

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
        }];
    }else{

         //moves everything down and changes "cancel" to "signup"
        [sender setTitle:@"Sign-Up" forState:UIControlStateNormal];
        [sender setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

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
            sender.enabled = NO;
            self.licensePlateTextField.text = @"";
            self.passwordField.text = @"";

        }completion:^(BOOL finished){
            sender.enabled = YES;
            self.emailTextField.hidden = YES;
        }];
    }
}

//Allows user to log in
- (IBAction)onLogInTapped:(UIButton *)sender{
    NSString  *username = self.licensePlateTextField.text;
    NSString *password = self.passwordField.text;

    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
        if (user) {
            NSLog(@"User logged in");
            [self performSegueWithIdentifier:@"initialSegue" sender:self];
        }else{
            NSLog(@"User can not log in");

            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:[NSString stringWithFormat:@"The email or password you entered is incorrect."] delegate:self cancelButtonTitle:@"Retry" otherButtonTitles:@"Forgot password", nil];
            [alertView show];

            self.licensePlateTextField.text = @"";
            self.passwordField.text = @"";
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

//when user touches cancel on forget password, returns to login
- (IBAction)onCancelResetPasswordButtonPressed:(id)sender {
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

//Sends email to user to request password
- (IBAction)onDoneButtonPressed:(id)sender {
    NSString *email = self.forgotPasswordTextField.text;

    [PFUser requestPasswordResetForEmailInBackground:email block:^(BOOL succeeded, NSError *error) {

        if (error) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Invalid Email Address Try Again" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
            [alertView show];

        } else {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Please check your email to complete password reset" message:nil delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
            [alertView show];

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
