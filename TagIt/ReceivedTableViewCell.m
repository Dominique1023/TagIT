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
        PFUser *blockedUser = [self.message objectForKey:@"from"];
        PFUser *currentUser = [PFUser currentUser];
        NSMutableArray * blockedUsersArray = [currentUser[@"blockedUsers"] mutableCopy];

        if (blockedUsersArray == nil) {
            blockedUsersArray = [NSMutableArray new];
        }

        BOOL isTheUserThere = NO;

        for (PFUser * user in blockedUsersArray) {
            if ([user.objectId isEqualToString:blockedUser.objectId]) {
                isTheUserThere = YES;
                break;
            }
        }

        if (isTheUserThere == NO) {
            [blockedUsersArray addObject:blockedUser];
            currentUser[@"blockedUsers"] = blockedUsersArray;
        }

        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self.delegate reloadReceivedTableView];
        }];
    }
}

@end
