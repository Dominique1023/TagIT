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

@end

@implementation ImageViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    NSData * imageData = [self.object[@"photo"] getData];
    self.imageView.image = [UIImage imageWithData:imageData];
}

@end
