//
//  SentTableViewCell.h
//  TagIt
//
//  Created by Alex Hudson, Dominique Vasquez, Steven Sickler on 8/26/14.
//  Copyright (c) 2014 RoadRage. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SentTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UITextView *userMessageView;
@property (strong, nonatomic) IBOutlet UILabel *receiverLabel;
@property (strong, nonatomic) IBOutlet UIImageView *myImageView;
@property (strong, nonatomic) IBOutlet UILabel *toLabel;

@end
