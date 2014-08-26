//
//  SentTableViewCell.h
//  TagIt
//
//  Created by Alex Hudson on 8/26/14.
//  Copyright (c) 2014 MobileMakers. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SentTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UITextView *userMessageView;
@property (strong, nonatomic) IBOutlet UILabel *receiverLabel;
@property (strong, nonatomic) IBOutlet UIImageView *myImageView;

@end
