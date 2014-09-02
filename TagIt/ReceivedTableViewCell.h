//
//  ReceivedTableViewCell.h
//  TagIt
//
//  Created by Alex Hudson on 8/27/14.
//  Copyright (c) 2014 MobileMakers. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReceivedTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *receivedImageView;
@property (strong, nonatomic) IBOutlet UITextView *receivedMessage;
@property (weak, nonatomic) IBOutlet UIButton *blockButton;
@property NSMutableArray *blockedUsers;
@property PFObject *message; 

-(IBAction)onBlockButtonPressed:(id)sender;

@end
