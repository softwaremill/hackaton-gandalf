//
//  ViewController.m
//  Gandalf
//
//  Created by Tomasz Szymanski on 07/02/14.
//  Copyright (c) 2014 SoftwareMill. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property(weak, nonatomic) IBOutlet UIImageView *image;
@property(weak, nonatomic) IBOutlet UILabel *label;
@property(weak, nonatomic) IBOutlet UITextField *input;
@property(strong, nonatomic) CLBeaconRegion *region;
@property(strong, nonatomic) CLLocationManager *locationManager;
@property(strong, nonatomic) NSNumber *currentMajor;
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

    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:ESTIMOTE_BEACON];

    _region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"com.softwaremill.gandalf"];
    _region.notifyEntryStateOnDisplay = YES;

    CLBeaconRegion *region1 = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:2784 identifier:@"com.softwaremill.gandalf1"];
    region1.notifyEntryStateOnDisplay = YES;

    CLBeaconRegion *region2 = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:5728 identifier:@"com.softwaremill.gandalf2"];
    region2.notifyEntryStateOnDisplay = YES;

    CLBeaconRegion *region3 = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:17819 identifier:@"com.softwaremill.gandalf2"];
    region3.notifyEntryStateOnDisplay = YES;

    [self.locationManager startMonitoringForRegion:_region];
    [self.locationManager requestStateForRegion:_region];

    [self.locationManager startMonitoringForRegion:region1];
    [self.locationManager requestStateForRegion:region1];

    [self.locationManager startMonitoringForRegion:region2];
    [self.locationManager requestStateForRegion:region2];

    [self.locationManager startMonitoringForRegion:region3];
    [self.locationManager requestStateForRegion:region3];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    [self.label setText:@"in region"];
    NSLog(@"in region");

    [_label setText:@"in region"];

    [_locationManager startRangingBeaconsInRegion:_region];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    [self.label setText:@"left region"];
    NSLog(@"out region");

    [self clearImage];

    [_locationManager stopRangingBeaconsInRegion:_region];
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    NSLog(@"Ranged beacons: %@", beacons);

    CLBeacon *closest = nil;
    int maxRssi = -1000;

    for (CLBeacon *beacon in beacons) {
        if (beacon.proximity == CLProximityImmediate || beacon.proximity == CLProximityNear) {
            if (beacon.rssi > maxRssi) {
                closest = beacon;
            }
        }
    }

    if (closest != nil) {
        NSLog(@"Closest: %@", closest);
        [self loadImage:closest.major];
    } else {
        NSLog(@"Clear");
        [self clearImage];
    }
}

- (void)loadImage:(NSNumber *)major {
    if (_currentMajor.intValue != major.intValue) {
        NSLog(@"change %@ %@", _currentMajor, major);

        _currentMajor = major;
        NSMutableURLRequest *request = [NSMutableURLRequest
                requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://warski.org/gandalf/%@.json", major]]];

        [request setHTTPMethod:@"GET"];

        NSError *error = nil;
        NSURLResponse *urlResponse = nil;

        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];

        NSLog(@"Got response %@", urlResponse);
        NSLog(@"Got error %@", error);
        NSLog(@"Got data %@", [NSString stringWithUTF8String:data.bytes]);

        NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];

        NSLog(@"Got json: %@", json);
        NSLog(@"Got name: %@", [json valueForKey:@"name"]);

        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.alertBody = [NSString stringWithFormat:@"Found %@ near by! Watch out.", [json valueForKey:@"name"]];
        notification.soundName = UILocalNotificationDefaultSoundName;

        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];

        NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[json valueForKey:@"pic"]]];
        UIImage *image = [UIImage imageWithData:imageData];

        [_image setImage:image];
    }
}

- (void)clearImage {
    [_image setImage: nil];
    [_label setText: @""];
}


- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    NSLog(@"Determined state %d for region %@", state, region);
}


@end
