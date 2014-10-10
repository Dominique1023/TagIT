//
//  ReceivedTableViewCell.m
//  TagIt
//
//  Created by Alex Hudson, Dominique Vasquez, Steven Sickler on 8/27/14.
//  Copyright (c) 2014 RoadRage. All rights reserved.
//

#import "ReceivedTableViewCell.h"
#import <MessageUI/MessageUI.h>

@interface ReceivedTableViewCell() <UIAlertViewDelegate>
@property UIAlertView *blockAlertView;
@property UIAlertView *reportUserAlertView;
@end

@implementation ReceivedTableViewCell

- (IBAction)onBlockButtonPressed:(id)sender {
    self.blockAlertView = [[UIAlertView alloc] initWithTitle:@"Warning!" message:@"Are you sure you want to block all messages from this license plate" delegate:self cancelButtonTitle:@"Nevermind" otherButtonTitles:@"I'm Sure", nil];

    [self.blockAlertView show];
}

- (IBAction)onReportUserButtonPressed:(id)sender {
    //disables the button so the user doesn't report the user twice and spam us
    self.reportUserButton.tintColor = [UIColor lightGrayColor];
    self.reportUserButton.enabled = NO;

}


-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(self.blockAlertView == alertView) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            //grabbing the current user to access the blockedUsers array on parse
            PFUser *currentUser = [PFUser currentUser];

            //creating a new instance of a PFUser pointing at blockedUser and setting it
            //to the "from" on ReceivedTableViewCell
            PFUser *blockedUser = [self.message objectForKey:@"from"];

            //creating a new array filling it with Users that are currently blocked
            NSMutableArray * blockedUsersArray = [currentUser[@"blockedUsers"] mutableCopy];

            //if the currentUser hasn't blocked anyone than init a new NSMutableArray
            if (blockedUsersArray == nil){
                blockedUsersArray = [NSMutableArray new];
            }

            //Asing if the blocked has already been blocked
            BOOL isTheUserThere = NO;

            //looking at every user in the blockedUsersArray and checking if its already been blocked
            for (PFUser * user in blockedUsersArray) {

                //if the user is NOT apart of the blockedUsersArray meaning they're not blocked
                if ([user.objectId isEqualToString:blockedUser.objectId]) {

                    //than YES the user is there and break to stop looking
                    isTheUserThere = YES;
                    break;
                }
            }

            //for the users that are not in the blockedUsersArray, add and update the currentUsers blocked
            if (isTheUserThere == NO) {
                [blockedUsersArray addObject:blockedUser];
                currentUser[@"blockedUsers"] = blockedUsersArray;
            }

            //regardless if the user is already blocked or not than save the currentUser
            [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [self.delegate reloadReceivedTableView];
            }];
        }//end of if on line 39
    }//end of if on line 38


//    if (self.reportUserAlertView == alertView) {
//        if (buttonIndex != alertView.cancelButtonIndex) {
//
//
//            [self sendEmail];
//
//
//
//        }//end of if on line 83
//    }//end of if on line 84

}
















@end
