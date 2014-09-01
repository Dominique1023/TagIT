//
//  SentReceiveViewController.m
//  TagIt
//
//  Created by Alex Hudson on 8/26/14.
//  Copyright (c) 2014 MobileMakers. All rights reserved.
//

#import "SentReceiveViewController.h"
#import "SentTableViewCell.h"
#import "ReceivedTableViewCell.h"
#import "ImageViewController.h"

@interface SentReceiveViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *sentTableView;
@property (strong, nonatomic) IBOutlet UITableView *receivedTableView;
@property NSMutableArray *receivedMessages;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property NSArray *sentMessages;

@end

@implementation SentReceiveViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self loadSentMessages];
    [self loadReceivedMessages];

    //self.segmentedControl.backgroundColor = [UIColor whiteColor];
    self.segmentedControl.tintColor = [UIColor whiteColor];
    self.receivedTableView.hidden = YES;

}

#pragma mark QUERYING FOR MESSAGES SENT AND RECEIVED

-(void)loadSentMessages{
    //Tells which class to look at
    PFQuery *query = [PFQuery queryWithClassName:@"Message"];

    // Retrieve the most recent ones
    [query orderByDescending:@"createdAt"];

    [query whereKey:@"from" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

        self.sentMessages = objects;
        [self.sentTableView reloadData];
    }];
}

-(void)loadReceivedMessages{
    //Tells which class to look at
    PFQuery *query = [PFQuery queryWithClassName:@"Message"];
    [query whereKey:@"to" equalTo:[PFUser currentUser].username];

    // Retrieve the most recent ones
    [query orderByDescending:@"createdAt"];

    [query includeKey:@"from"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){

        self.receivedMessages = objects.mutableCopy;

        PFUser * user = [PFUser currentUser];

        NSMutableArray * blockedUsers = user[@"blockedUsers"];
        NSLog(@" blocked users %@", blockedUsers);

        for (int i = 0; i < blockedUsers.count; i++) {
            for (int y =0; y < self.receivedMessages.count; y++) {
                PFObject * message = [self.receivedMessages objectAtIndex:y];

                PFUser * bUser = message [@"from"];

                if ([[blockedUsers objectAtIndex:i] isEqualToString:bUser.username]){
                    [self.receivedMessages removeObjectAtIndex:y];
                }
            }
        }

        [self.receivedTableView reloadData];
    }];
}




#pragma mark TABLEVIEW DELEGATE AND DATASOURCE METHODS


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.sentTableView == tableView){
        return self.sentMessages.count;
    }else{
        return self.receivedMessages.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.sentTableView){
        SentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];

        PFObject *tempObject = [self.sentMessages objectAtIndex:indexPath.row];
        cell.userMessageView.text = tempObject[@"text"];
        cell.receiverLabel.text = tempObject[@"to"];

        NSData * imageData = [tempObject[@"photo"] getData];
        cell.myImageView.image = [UIImage imageWithData:imageData];

        return cell;
    }else{
        ReceivedTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"RCell"];

        PFObject *tempObject = [self.receivedMessages objectAtIndex:indexPath.row];
        cell.receivedMessage.text = tempObject[@"text"];

        NSData * imageData = [tempObject[@"photo"] getData];
        cell.receivedImageView.image = [UIImage imageWithData:imageData];

        return cell;
    }

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    ImageViewController * vc = segue.destinationViewController;

    if ([segue.identifier isEqualToString:@"receivedPhotoSegue"]) {
        NSIndexPath * indexPath = [self.receivedTableView indexPathForSelectedRow];
        vc.object =  [self.receivedMessages objectAtIndex:indexPath.row];
    }
    else if ([segue.identifier isEqualToString:@"sentPhotoSegue"]){
        NSIndexPath * indexPath = [self.sentTableView indexPathForSelectedRow];
        vc.object =  [self.sentMessages objectAtIndex:indexPath.row];
    }
}

- (IBAction)toggleControl:(UISegmentedControl *)control{
    if (control.selectedSegmentIndex == 0) {
        self.receivedTableView.hidden = YES;
        self.sentTableView.hidden = NO;

    }else{
        self.sentTableView.hidden = YES;
        self.receivedTableView.hidden = NO;
    }
}




@end
