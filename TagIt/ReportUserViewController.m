//
//  ReportUserViewController.m
//  RoadRage
//
//  Created by Dominique on 9/20/14.
//  Copyright (c) 2014 MobileMakers. All rights reserved.
//

#import "ReportUserViewController.h"
#import <MessageUI/MessageUI.h>

@interface ReportUserViewController ()<MFMailComposeViewControllerDelegate>
@property MFMailComposeViewController *mailComposer;


@end

@implementation ReportUserViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
}

/*
 the bug im getting is the code is in the view did appear so everytime the view is coming up it shows the mail composer and it never runs
 the performSegueWithIdentifier method
 
 i dont know where to put lines 38 - 48 (mailComposer Code) so that it only runs once. i've tried a helper method and call it view did load and it gave me a error and said to put in viewDidAppear or ViewDidDisapper.
 
doing it in a way so that when the user presses "report user" button it sends us an automated message will probably get rid of this bug 

 */

-(void)viewDidAppear:(BOOL)animated{

    //automatically sets the recipent to us     *** add @"alexhudson07@gmail.com", or @"steven.sickler@yahoo.com" to test   ****
    NSArray *recipent = [[NSArray alloc]initWithObjects:@"dominiquev91@gmail.com", nil];

    //inits a new mail composer and sets properties
    self.mailComposer = [MFMailComposeViewController new];
    self.mailComposer.mailComposeDelegate = self;
    [self.mailComposer setSubject:@"Test Mail"];
    [self.mailComposer setMessageBody:@"Test message for test mail" isHTML:NO];
    [self.mailComposer setToRecipients:recipent];

    [self presentViewController:self.mailComposer animated:YES completion:nil];
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    if (error) {
        NSLog(@"Error: %@", error);
    }else{
        NSLog(@"Success");

    }

    [self dismissViewControllerAnimated:YES completion:^{
        [self performSegueWithIdentifier:@"reportUserSegue" sender:self];
    }];
 
}

@end













