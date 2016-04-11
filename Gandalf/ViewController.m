//
//  ViewController.m
//  Gandalf
//
//  Created by Tomasz Szymanski on 07/02/14.
//  Copyright (c) 2014 SoftwareMill. All rights reserved.
//

#import "ViewController.h"
#import "ImageViewController.h"

@interface ViewController ()
@property(weak, nonatomic) IBOutlet UILabel *label;
@property(weak, nonatomic) IBOutlet UITextField *input;
@property(strong, nonatomic) CLBeaconRegion *region;
@property(strong, nonatomic) CLLocationManager *locationManager;
@property(strong, nonatomic) NSNumber *currentMajor;
@property(strong, nonatomic) NSUUID *uuid;
@property(weak, nonatomic) IBOutlet UILabel *jarek;
@property(weak, nonatomic) IBOutlet UILabel *jasiek;
@property(weak, nonatomic) IBOutlet UILabel *pawel;
@property(strong, nonatomic) NSDictionary *labelsFromMajors;
@property(strong, nonatomic) ImageViewController *imageViewController;
@property(strong, nonatomic) UIImage *imageToShow;
@end

@implementation ViewController

static CLBeaconMajorValue MAJORS[] = {2784, 5728, 17819};

- (IBAction)onClick:(id)sender {
    [self.label setText:self.input.text];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _uuid = [[NSUUID alloc] initWithUUIDString:ESTIMOTE_BEACON];

    _labelsFromMajors = @{@"2784" : _pawel, @"5728" : _jarek, @"17819" : _jasiek};

    // Do any additional setup after loading the view, typically from a nib.

    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;


    _region = [[CLBeaconRegion alloc] initWithProximityUUID:_uuid identifier:@"com.softwaremill.gandalf"];
    _region.notifyEntryStateOnDisplay = YES;

    [self.locationManager startMonitoringForRegion:_region];
    [self.locationManager requestStateForRegion:_region];

    for (int j = 0; j < sizeof(MAJORS) / sizeof(CLBeaconMajorValue); j++) {
        NSLog(@"using major %d", MAJORS[j]);
        [self initRegion:MAJORS[j]];
    }

    [_jarek setText:@"Jarek not found"];
    [_jasiek setText:@"Jasiek not found"];
    [_pawel setText:@"Pawel not found"];
}

- (void)initRegion:(CLBeaconMajorValue)major {
    CLBeaconRegion *region1 = [[CLBeaconRegion alloc] initWithProximityUUID:_uuid major:major identifier:@"com.softwaremill.gandalf1"];
    region1.notifyEntryStateOnDisplay = YES;

    [self.locationManager startMonitoringForRegion:region1];
    [self.locationManager requestStateForRegion:region1];
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
        NSObject *guyName = [json valueForKey:@"name"];

        NSLog(@"Got name: %@", guyName);

        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.alertBody = [NSString stringWithFormat:@"Found %@ near by! Watch out.", guyName];
        notification.soundName = UILocalNotificationDefaultSoundName;

        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];

        NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[json valueForKey:@"pic"]]];
        _imageToShow = [UIImage imageWithData:imageData];

        [self performSegueWithIdentifier:@"showImage" sender:self];
        
        [[_labelsFromMajors valueForKey:[NSString stringWithFormat:@"%@", major]] 
                setText:[NSString stringWithFormat:@"%@ found!", guyName]];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ImageViewController *imageView = (ImageViewController*)segue.destinationViewController;
    [imageView setPicture: _imageToShow];
}


- (void)clearImage {
    [_label setText:@""];
}


- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    NSLog(@"Determined state %ld for region %@", (long)state, region);
}


@end
