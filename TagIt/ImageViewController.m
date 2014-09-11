//
//  ImageViewController.m
//  TagIt
//
//  Created by Alex Hudson, Dominique Vasquez, Steven Sickler on 8/27/14.
//  Copyright (c) 2014 RoadRage. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *mySentFeedTableView;
@property (strong, nonatomic) IBOutlet UILabel *sentLabel;
@property NSArray *sentFeed;

@end

@implementation ImageViewController

- (void)viewDidLoad{

    [super viewDidLoad];

    self.sentLabel.text = self.object[@"to"];

    self.mySentFeedTableView.separatorColor = [UIColor clearColor];

    PFQuery *query = [PFQuery queryWithClassName:@"Message"];

    [query whereKey:@"to" equalTo:self.object[@"to"]];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

        self.sentFeed = objects;
        [self.mySentFeedTableView reloadData];
    }];
}

#pragma mark TABLEVIEW DELEGATE AND DATASOURCE METHODS

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.sentFeed.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    FeedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myCellID"];

    PFObject *tempObject = [self.sentFeed objectAtIndex:indexPath.row];
    cell.mySentTextView.text = tempObject[@"text"];
    cell.mySentTextView.textColor = [UIColor grayColor];

    [tempObject[@"photo"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {

        cell.mySentImageView.layer.cornerRadius=8;
        cell.mySentImageView.layer.borderWidth=2.0;
        cell.mySentImageView.layer.masksToBounds = YES;
        cell.mySentImageView.layer.borderColor = [[UIColor colorWithRed:253.f/255.f green:80.f/255.f blue:80.f/255.f alpha:1.f] CGColor];

        //if the user wasn't sent a photo than a placeholder image will be sent
        if (data == nil){
            UIImage *image = [UIImage imageNamed:@"FillerIcon"];
            NSData *imageData = UIImagePNGRepresentation(image);
            data = imageData;
        }

        cell.mySentImageView.image = [UIImage imageWithData:data];
    }];

    return cell;
}

@end


