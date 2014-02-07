//
//  ViewController.m
//  Gandalf
//
//  Created by Tomasz Szymanski on 07/02/14.
//  Copyright (c) 2014 SoftwareMill. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property(weak, nonatomic) IBOutlet UILabel *label;
@property(weak, nonatomic) IBOutlet UITextField *input;
@property(strong, nonatomic) CLBeaconRegion *region;
@property(strong, nonatomic) CLLocationManager *locationManager;
@end

@implementation ViewController

- (IBAction)onClick:(id)sender {
    [self.label setText:self.input.text];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;

    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6"];

    self.region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"com.softwaremill.gandalf"];

    self.region.notifyEntryStateOnDisplay = YES;

    [self.locationManager startMonitoringForRegion:_region];

    [self.locationManager requestStateForRegion:_region];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    [self.label setText:@"in region"];
    NSLog(@"in region");
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    [self.label setText:@"out region"];
    NSLog(@"out region");
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    NSLog(@"Determined state %d for region %@", state, region);

    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = [NSString stringWithFormat:@"Region change %d", state];
    notification.soundName = UILocalNotificationDefaultSoundName;

    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}


@end
