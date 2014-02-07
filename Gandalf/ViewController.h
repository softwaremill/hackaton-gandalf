//
//  ViewController.h
//  Gandalf
//
//  Created by Tomasz Szymanski on 07/02/14.
//  Copyright (c) 2014 SoftwareMill. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

static NSString *const ADAM_BEACON = @"2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6";
static NSString *const TOMEK_BEACON = @"B0702880-A295-A8AB-F734-031A98A512DE";
static NSString *const ESTIMOTE_BEACON = @"B9407F30-F5F8-466E-AFF9-25556B57FE6D";

@interface ViewController : UIViewController<CLLocationManagerDelegate>

@end
