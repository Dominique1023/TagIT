//
//  ReceivedTableViewCell.m
//  TagIt
//
//  Created by Alex Hudson on 8/27/14.
//  Copyright (c) 2014 MobileMakers. All rights reserved.
//

#import "ReceivedTableViewCell.h"
@interface ReceivedTableViewCell() <UIAlertViewDelegate>
@end

@implementation ReceivedTableViewCell

- (IBAction)onBlockButtonPressed:(id)sender {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Warning!" message:@"Are you sure you want to block all messages from this license plate" delegate:self cancelButtonTitle:@"Nevermind" otherButtonTitles:@"I'm Sure", nil];
    [alert show];

}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        //grabbing the current user to access the blockedUsers array on parse
        PFUser *currentUser = [PFUser currentUser];

        //creating a new instance of a PFUser pointing at blockedUser and setting it
        //to the "from" on ReceivedTableViewCell
        PFUser *blockedUser = [self.message objectForKey:@"from"];

        //creating a new array filling it with Users that are currently blocked
        NSMutableArray * blockedUsersArray = [currentUser[@"blockedUsers"] mutableCopy];

        //if the currentUser hasn't blocked anyone than init a new NSMutableArray
        if (blockedUsersArray == nil) {
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
    }
}

@end
