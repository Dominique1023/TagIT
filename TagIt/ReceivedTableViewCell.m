//
//  ReceivedTableViewCell.m
//  TagIt
//
//  Created by Alex Hudson on 8/27/14.
//  Copyright (c) 2014 MobileMakers. All rights reserved.
//

#import "ReceivedTableViewCell.h"

@implementation ReceivedTableViewCell

- (IBAction)onBlockButtonPressed:(id)sender {
    PFUser *blockedUser = [self.message objectForKey:@"from"];

    NSLog(@"%@", blockedUser);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
}

@end
