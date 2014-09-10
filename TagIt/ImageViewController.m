//
//  ImageViewController.m
//  TagIt
//
//  Created by Alex Hudson on 8/27/14.
//  Copyright (c) 2014 MobileMakers. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *mySentFeedTableView;
@property NSArray * sentFeed;
@property (strong, nonatomic) IBOutlet UILabel *sentLabel;

@end

@implementation ImageViewController

- (void)viewDidLoad{


    [super viewDidLoad];

    self.sentLabel.text = self.object[@"to"];

    self.mySentFeedTableView.separatorColor = [UIColor clearColor];


    PFQuery *query = [PFQuery queryWithClassName:@"Message"];

   // [query whereKey:@"to" equalTo:@"domi"];
    [query whereKey:@"to" equalTo:self.object[@"to"]];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"%@", objects);

        self.sentFeed = objects;
        [self.mySentFeedTableView reloadData];
    }];

    NSLog(@"%@", self.object);

    NSLog(@"%@",query);
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
        cell.mySentImageView.layer.borderColor = [[UIColor colorWithRed:208.f/255.f green:2.f/255.f blue:27.f/255.f alpha:1.f] CGColor];

        if (data == nil)
        {
            UIImage *image = [UIImage imageNamed:@"FillerIcon"];
            NSData *imageData = UIImagePNGRepresentation(image);
            data = imageData;
        }


        cell.mySentImageView.image = [UIImage imageWithData:data];
    }];
    
    
    return cell;
}

@end


