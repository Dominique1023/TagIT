//
//  SettingsViewController.m
//  TagIt
//
//  Created by Steven Sickler on 8/27/14.
//  Copyright (c) 2014 MobileMakers. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

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



@end
