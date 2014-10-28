//
//  SentReceiveViewController.m
//  TagIt
//
//  Created by Alex Hudson, Dominique Vasquez, Steven Sickler on 8/26/14.
//  Copyright (c) 2014 RoadRage. All rights reserved.
//

#import "SentReceiveViewController.h"
#import "SentTableViewCell.h"
#import "ReceivedTableViewCell.h"
#import "ImageViewController.h"
#import "ReportUserViewController.h"

@interface SentReceiveViewController () <UITableViewDataSource, UITableViewDelegate, ReceivedTableViewCellDelegate>
@property (strong, nonatomic) IBOutlet UITableView *sentTableView;
@property (strong, nonatomic) IBOutlet UITableView *receivedTableView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (strong, nonatomic) IBOutlet UIButton *refreshButton;
@property NSArray *sentMessages;
@property NSMutableArray *receivedMessages;
@property NSInteger iPath;
@property ReceivedTableViewCell *rCell;

@end

@implementation SentReceiveViewController

- (void)viewDidLoad{

    [super viewDidLoad];
    [self loadSentMessages];
    [self loadReceivedMessages];

    self.sentTableView.separatorColor = [UIColor clearColor];
    self.receivedTableView.separatorColor = [UIColor clearColor];

    self.refreshButton.hidden = YES; 

    //self.segmentedControl.backgroundColor = [UIColor whiteColor];
    self.segmentedControl.tintColor = [UIColor whiteColor];
    self.refreshButton.tintColor = [UIColor whiteColor];
    self.receivedTableView.hidden = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadSentMessages) name:@"onSendButtonPressed" object:nil];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadReceivedMessages) name:@"Unblock and reload" object:nil];
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
    PFQuery *query = [PFQuery queryWithClassName:@"Message"];
    [query whereKey:@"to" equalTo:[PFUser currentUser].username];

    [query whereKey:@"from" notContainedIn:[PFUser currentUser][@"blockedUsers"]];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.receivedMessages = objects.mutableCopy;

        [self.receivedTableView reloadData];
    }];
}

- (IBAction)onRefreshButtonPressed:(id)sender{
    [self loadReceivedMessages];
    [self loadSentMessages];
}

-(void)reloadReceivedTableView{
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
        cell.userMessageView.textColor = [UIColor grayColor];
        cell.receiverLabel.text = tempObject[@"to"];
        cell.toLabel.textColor =[UIColor colorWithRed:250.f/255.f green:80.f/255.f blue:84.f/255.f alpha:1.f];

        [tempObject[@"photo"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (data == nil){
                UIImage *image = [UIImage imageNamed:@"FillerIcon"];
                NSData *imageData = UIImagePNGRepresentation(image);
                data = imageData;
            }

            cell.myImageView.layer.cornerRadius=8;
            cell.myImageView.layer.borderWidth=2.0;
            cell.myImageView.layer.masksToBounds = YES;
            cell.myImageView.layer.borderColor= [[UIColor colorWithRed:253.f/255.f green:80.f/255.f blue:80.f/255.f alpha:1.f] CGColor];
            cell.myImageView.image = [UIImage imageWithData:data];

        }];

        return cell;

    }else{
        self.rCell = [tableView dequeueReusableCellWithIdentifier:@"RCell"];
        self.rCell.delegate = self;

        self.rCell.reportUserButton.tag = indexPath.row;

        PFObject *tempObject = [self.receivedMessages objectAtIndex:indexPath.row];

        self.rCell.receivedMessage.text = tempObject[@"text"];
        self.rCell.receivedMessage.textColor = [UIColor grayColor];
        self.rCell.reportUserButton.tintColor = [UIColor colorWithRed:253.f/255.f green:80.f/255.f blue:80.f/255.f alpha:1.f];
        self.rCell.blockButton.tintColor = [UIColor colorWithRed:253.f/255.f green:80.f/255.f blue:80.f/255.f alpha:1.f];
        self.rCell.message = tempObject;

        [tempObject[@"photo"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error){

            //if the user doesn't send a photo than a placeholder image will be set
            if (data == nil){
                UIImage *image = [UIImage imageNamed:@"FillerIcon"];
                NSData *imageData = UIImagePNGRepresentation(image);
                data = imageData;
            }

            self.rCell.receivedImageView.layer.cornerRadius=8;
            self.rCell.receivedImageView.layer.borderWidth=2.0;
            self.rCell.receivedImageView.layer.masksToBounds = YES;
            self.rCell.receivedImageView.layer.borderColor = [[UIColor colorWithRed:253.f/255.f green:80.f/255.f blue:80.f/255.f alpha:1.f] CGColor];

            self.rCell.receivedImageView.image = [UIImage imageWithData:data];
        }];
        return self.rCell;
    }
}

- (IBAction)reportUser:(id)sender {
    [self performSegueWithIdentifier:@"SRReportUserSegue" sender:self];
}



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    ImageViewController *vc = segue.destinationViewController;

    if ([segue.identifier isEqualToString:@"receivedPhotoSegue"]) {

        NSIndexPath *indexPath = [self.receivedTableView indexPathForSelectedRow];
        vc.object = [self.receivedMessages objectAtIndex:indexPath.row];
        
    }else if ([segue.identifier isEqualToString:@"sentPhotoSegue"]){
        NSIndexPath *indexPath = [self.sentTableView indexPathForSelectedRow];
        vc.object = [self.sentMessages objectAtIndex:indexPath.row];

    }else if([segue.identifier isEqualToString:@"SRReportUserSegue"]){
        ReportUserViewController *rvc = segue.destinationViewController;

        PFObject *reportedUser = [self.receivedMessages objectAtIndex:self.rCell.iPath];
        NSString *messageID = reportedUser.objectId;

        rvc.reportedMessage = messageID;




    }
}

//Because there is a two tableviews in one screen
- (IBAction)toggleControl:(UISegmentedControl *)control{
    if (control.selectedSegmentIndex == 0) {
        self.receivedTableView.hidden = YES;
        self.sentTableView.hidden = NO;
        [self loadSentMessages];
    }else{
        self.sentTableView.hidden = YES;
        self.receivedTableView.hidden = NO;
        [self loadReceivedMessages];
    }
}

@end
