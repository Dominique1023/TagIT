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

@interface SentReceiveViewController () <UITableViewDataSource, UITableViewDelegate, ReceivedTableViewCellDelegate>
@property (strong, nonatomic) IBOutlet UITableView *sentTableView;
@property (strong, nonatomic) IBOutlet UITableView *receivedTableView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property NSArray *sentMessages;
@property NSMutableArray *receivedMessages;
@property (strong, nonatomic) IBOutlet UIButton *refreshButton;

@end

@implementation SentReceiveViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self loadSentMessages];
    [self loadReceivedMessages];

    //self.segmentedControl.backgroundColor = [UIColor whiteColor];
    self.segmentedControl.tintColor = [UIColor whiteColor];
    self.refreshButton.tintColor = [UIColor whiteColor];
    self.receivedTableView.hidden = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadSentMessages) name:@"onSendButtonPressed" object:nil];
}

#pragma mark QUERYING FOR MESSAGES SENT AND RECEIVED
-(void)loadSentMessages{
    //Tells which class to look at
    PFQuery *query = [PFQuery queryWithClassName:@"Message"];

    [query whereKey:@"from" equalTo:[PFUser currentUser]];

    // Retrieve the most recent ones
    [query orderByDescending:@"createdAt"];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

        self.sentMessages = objects;
        [self.sentTableView reloadData];
    }];
}

-(void)loadReceivedMessages{
    //Tells which class to look at
    PFQuery *query = [PFQuery queryWithClassName:@"Message"];
    [query whereKey:@"to" equalTo:[PFUser currentUser].username];

    [query whereKey:@"from" notContainedIn:[PFUser currentUser][@"blockedUsers"]];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.receivedMessages = objects.mutableCopy;
        [self.receivedTableView reloadData];
    }];

}

- (IBAction)onRefreshButtonPressed:(id)sender {
    [self loadReceivedMessages];
    [self loadSentMessages];
}

-(void)reloadReceivedTableView
{
    [self loadReceivedMessages];
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

        [tempObject[@"photo"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            cell.myImageView.image = [UIImage imageWithData:data];
        }];


        return cell;
    }else{
        ReceivedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RCell"];

        cell.delegate = self;

        PFObject *tempObject = [self.receivedMessages objectAtIndex:indexPath.row];
        cell.receivedMessage.text = tempObject[@"text"];
        
        cell.message = tempObject;

        [tempObject[@"photo"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            cell.receivedImageView.image = [UIImage imageWithData:data];
        }];


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
