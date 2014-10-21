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
@property BOOL hasSent;

@end

@implementation ReportUserViewController

- (void)viewDidLoad{
    [super viewDidLoad];

    self.hasSent = NO;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES]; 

    if (self.hasSent == YES) {
        [self performSegueWithIdentifier:@"reportUserSegue" sender:self];
    }else if(self.hasSent == NO){

        [self sendingEmail];
        self.hasSent = YES; 
    }

}

-(void)sendingEmail{
    //grabbing the user's information so we know who is the one doing the reporting
    //Also grabbing the message the user received 

    PFUser *currentUser = [PFUser currentUser];
    NSString *currentUserObjectID = currentUser.objectId;
    NSString *currentUserUserName = [[PFUser currentUser] username];

    //automatically sets the recipent to us     *** add @"alexhudson07@gmail.com", or @"steven.sickler@yahoo.com" to test   ****
    NSArray *recipent = [[NSArray alloc]initWithObjects:@"dominiquev91@gmail.com", nil];

    //inits a new mail composer and sets properties
    self.mailComposer = [MFMailComposeViewController new];
    self.mailComposer.mailComposeDelegate = self;
    [self.mailComposer setSubject:[NSString stringWithFormat:@"Message ID: %@", self.reportedMessage]];
    [self.mailComposer setMessageBody: [NSString stringWithFormat:@" \n \n \n \n \n User ID: %@ \n License Plate: %@", currentUserObjectID, currentUserUserName] isHTML:NO];
    [self.mailComposer setToRecipients:recipent];

    [self presentViewController:self.mailComposer animated:YES completion:nil];
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    if (error) {
        NSLog(@"Error: %@", error);
    }

    [self dismissViewControllerAnimated:YES completion:^{
        [self performSegueWithIdentifier:@"reportUserSegue" sender:self];
    }];
}

@end












