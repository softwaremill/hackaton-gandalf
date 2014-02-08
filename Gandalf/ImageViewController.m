//
//  ImageViewController.m
//  Gandalf
//
//  Created by Tomasz Szymanski on 07/02/14.
//  Copyright (c) 2014 SoftwareMill. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (strong, nonatomic) UIImage *picture;
@end

@implementation ImageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"Image view is %@", _image);
    [_image setImage: _picture];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setPicture:(UIImage *)picture {
    NSLog(@"Setting picture %@", picture);
    _picture = picture;
}

@end
