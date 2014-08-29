//
//  SettingsViewController.m
//  TagIt
//
//  Created by Steven Sickler on 8/27/14.
//  Copyright (c) 2014 MobileMakers. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UITextField *blockedUserTextField;
@property NSMutableArray *blockedUsers;

@end

@implementation SettingsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (IBAction)logOutOnButtonPressed:(id)sen
{

    [PFUser logOut];
   
}

- (IBAction)onBlockUserButtonPressed:(id)sender
{
    PFUser *user = [PFUser currentUser];

    if (user[@"blockedUsers"]) {
        self.blockedUsers = user[@"blockedUsers"];
    }else{
        self.blockedUsers = [NSMutableArray new];
    }

    NSString *blockedUserString = self.blockedUserTextField.text;

    [self.blockedUsers insertObject:blockedUserString atIndex:0];

    user[@"blockedUsers"] = self.blockedUsers;

    [user saveInBackground];
}



@end
