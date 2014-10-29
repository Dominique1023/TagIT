//
//  ReceivedTableViewCell.h
//  TagIt
//
//  Created by Alex Hudson, Dominique Vasquez, Steven Sickler on 8/27/14.
//  Copyright (c) 2014 RoadRage. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ReceivedTableViewCellDelegate
-(void) reloadReceivedTableView;

@end

@interface ReceivedTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *receivedImageView;
@property (strong, nonatomic) IBOutlet UITextView *receivedMessage;
@property (weak, nonatomic) IBOutlet UIButton *blockButton;
@property (weak, nonatomic) IBOutlet UIButton *reportUserButton;
@property NSMutableArray *blockedUsers;
@property PFObject *message;
@property NSInteger iPath;
@property id<ReceivedTableViewCellDelegate> delegate;

-(IBAction)onBlockButtonPressed:(id)sender;
- (IBAction)onReportUserButtonPressed:(id)sender; 

@end
