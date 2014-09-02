//
//  ImageViewController.m
//  TagIt
//
//  Created by Alex Hudson on 8/27/14.
//  Copyright (c) 2014 MobileMakers. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@end

@implementation ImageViewController

- (void)viewDidLoad{
    [super viewDidLoad];

    //getting data for photo from parse 
    [self.object[@"photo"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        self.imageView.image = [UIImage imageWithData:data];
    }];

}

@end
