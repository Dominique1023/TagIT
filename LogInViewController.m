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
@property (weak, nonatomic) IBOutlet UILabel *roadRageLabel;
@property (weak, nonatomic) IBOutlet UIButton *createAccount;
@property (weak, nonatomic) IBOutlet UIButton *logInButton;
@property (weak, nonatomic) IBOutlet UIView *myView;
@property UIAlertView *forgotPasswordAlertView;
@property (weak, nonatomic) IBOutlet UILabel *forgotPasswordLabel;
@property (weak, nonatomic) IBOutlet UITextField *forgotPasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;


@end

@implementation LogInViewController



- (void)viewDidLoad{
    [super viewDidLoad];

    //Turning off autocorrect for license plate
    [self.licensePlate setAutocorrectionType:UITextAutocorrectionTypeNo];


    self.createAccount.hidden = YES;
    self.emailField.hidden = YES;
    self.forgotPasswordLabel.hidden = YES;
    self.forgotPasswordTextField.hidden = YES;
    self.doneButton.hidden = YES;

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
         //moves everything down and changes "cancel" to "signup"
        [sender setTitle:@"Sign-Up" forState:UIControlStateNormal];
        [sender setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

        [UIView animateWithDuration:1.2 animations:^{
            self.roadRageLabel.transform = CGAffineTransformMakeTranslation(0, -90);
            self.roadRageLabel.transform = CGAffineTransformMakeTranslation(0, 5);

            self.emailField.transform = CGAffineTransformMakeTranslation(0, -60);
            self.emailField.transform = CGAffineTransformMakeTranslation(0, 5);

            self.licensePlate.transform = CGAffineTransformMakeTranslation(0, -60);
            self.licensePlate.transform = CGAffineTransformMakeTranslation(0, 5);

            self.passwordField.transform = CGAffineTransformMakeTranslation(0, -60);
            self.passwordField.transform = CGAffineTransformMakeTranslation(0, 5);


            self.emailField.alpha = 0;
            self.createAccount.hidden = YES;
            self.logInButton.hidden = NO;
            sender.enabled = NO;
            self.licensePlate.text = @"";
            self.passwordField.text = @"";

        }completion:^(BOOL finished){
            sender.enabled = YES;
            self.emailField.hidden = YES;
        }];
    }
}

//Allows user to log in
- (IBAction)onLogInTapped:(UIButton *)sender{
    NSString  *username = self.licensePlate.text;
    NSString *password = self.passwordField.text;

    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
        if (user) {
            NSLog(@"User logged in");
            [self performSegueWithIdentifier:@"initialSegue" sender:self];
        }else{
            NSLog(@"User can not log in");

            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:[NSString stringWithFormat:@"The email or password you entered is incorrect."] delegate:self cancelButtonTitle:@"Retry" otherButtonTitles:@"Forgot password", nil];
            [alertView show];

            self.licensePlate.text = @"";
            self.passwordField.text = @"";
        }
    }];
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex != alertView.cancelButtonIndex) {
        self.forgotPasswordLabel.hidden = NO;
        self.forgotPasswordTextField.hidden = NO;
        self.roadRageLabel.hidden = YES;
        self.licensePlate.hidden = YES;
        self.passwordField.hidden = YES;
        self.logInButton.hidden = YES;
        self.signUpButton.hidden = YES;
        self.doneButton.hidden = NO;
    }
}


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
            self.licensePlate.hidden = NO;
            self.passwordField.hidden = NO;
            self.logInButton.hidden = NO;
            self.signUpButton.hidden = NO;
            self.doneButton.hidden = YES;
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
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:[NSString stringWithFormat:@"Looks like we have a small issue: %@", errorString] delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil, nil];

            [alertView show];
         }
    }];
}

#pragma mark TEXTFEILD DELEGATES 

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.emailField resignFirstResponder];
    [self.licensePlate resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [self.forgotPasswordTextField resignFirstResponder];

    return YES;
}


@end
