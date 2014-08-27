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

@interface SentReceiveViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *sentTableView;
@property (strong, nonatomic) IBOutlet UITableView *receivedTableView;
@property NSArray *receivedMessages;
@property NSArray *sentMessages;

@end

@implementation SentReceiveViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self loadSentMessages];
    [self receivedMessages];
     self.receivedTableView.hidden = YES;

}

-(void)loadSentMessages{
    //Tells which class to look at
    PFQuery *query = [PFQuery queryWithClassName:@"Message"];
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
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

        self.receivedMessages = objects;
        [self.receivedTableView reloadData];
    }];
}

- (IBAction)toggleControl:(UISegmentedControl *)control {

    if (control.selectedSegmentIndex == 0) {
        self.receivedTableView.hidden = YES;
        self.sentTableView.hidden = NO;

    } else {
        self.sentTableView.hidden = YES;
           self.receivedTableView.hidden = NO;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    if (self.sentTableView == tableView) {
        return self.sentMessages.count;
    } else{
        return self.receivedMessages.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    if (tableView == self.sentTableView) {
        SentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];

        PFObject *tempObject = [self.sentMessages objectAtIndex:indexPath.row];

        cell.userMessageView.text = tempObject[@"text"];
        cell.receiverLabel.text = tempObject[@"to"];

        NSData * imageData = [tempObject[@"photo"] getData];

        cell.myImageView.image = [UIImage imageWithData:imageData];

        return cell;
    } else {
        ReceivedTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"RCell"];

        PFObject *tempObject = [self.receivedMessages objectAtIndex:indexPath.row];
        cell.receivedMessage.text = tempObject[@"text"];

        NSData * imageData = [tempObject[@"photo"] getData];
        cell.receivedImageView.image = [UIImage imageWithData:imageData];
        return cell;
    }

}



@end
