//
//  SentReceiveViewController.m
//  TagIt
//
//  Created by Alex Hudson on 8/26/14.
//  Copyright (c) 2014 MobileMakers. All rights reserved.
//

#import "SentReceiveViewController.h"
#import "SentTableViewCell.h"

@interface SentReceiveViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property NSArray *messages;

@end

@implementation SentReceiveViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self loadMessages];
}

-(void)loadMessages{
    //Tells which class to look at
    PFQuery *query = [PFQuery queryWithClassName:@"Message"];

    [query whereKey:@"from" equalTo:[PFUser currentUser]];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

        self.messages = objects;
        [self.tableView reloadData];
    }];

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.messages.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];

    PFObject *tempObject = [self.messages objectAtIndex:indexPath.row];
    NSLog(@"%@", tempObject);
    cell.userMessageView.text = tempObject[@"text"];
    cell.receiverLabel.text = tempObject[@"to"];

    NSData * imageData = [tempObject[@"photo"] getData];

    cell.myImageView.image = [UIImage imageWithData:imageData];

    return cell;
}



@end
