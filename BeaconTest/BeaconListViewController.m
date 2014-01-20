//
//  BeaconListViewController.m
//  BeaconTest
//
//  Created by Jayden.Ma on 15/1/14.
//  Copyright (c) 2014 Jayden.Ma. All rights reserved.
//

#import "BeaconListViewController.h"
#import <ESTBeaconManager.h>
#import <ESTBeacon.h>

const int BEACON_1_MAJOR = 24134;
const int BEACON_1_MINOR = 18881;
const int BEACON_2_MAJOR = 51405;
const int BEACON_2_MINOR = 20560;
const int BEACON_3_MAJOR = 61181;
const int BEACON_3_MINOR = 41001;
const float MIN_DISTANCE = 0.1;
const double MIN_TIMEOUT = 3.0;

@interface BeaconListViewController ()

@property NSMutableArray *beacons;
@property (nonatomic, strong) ESTBeaconManager* beaconManager;
@property (nonatomic, strong) ESTBeacon* selectedBeacon;
@property BOOL isAlerted;
@property CFTimeInterval timestart1;
@property CFTimeInterval timestart2;
@property CFTimeInterval timestart3;

@end

@implementation BeaconListViewController

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.beacons count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ListPrototypeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    ESTBeacon *beacon = [self.beacons objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"Major:%@  Minor:%@  Distance:%#0.2f", beacon.major, beacon.minor, [beacon.distance floatValue]];
    
    return cell;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setupManager
{
    // create manager instance
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    
    // create sample region object (you can additionaly pass major / minor values)
    ESTBeaconRegion* region = [[ESTBeaconRegion alloc] initRegionWithIdentifier:@"EstimoteSampleRegion"];
    
    // start looking for estimote beacons in region
    // when beacon ranged beaconManager:didRangeBeacons:inRegion: invoked
    [self.beaconManager startRangingBeaconsInRegion:region];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isAlerted = false;
    self.beacons = [[NSMutableArray alloc] init];
    [self setupManager];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)beaconManager:(ESTBeaconManager *)manager
     didRangeBeacons:beacons
            inRegion:(ESTBeaconRegion *)region
{
    self.beacons = beacons;
    if([beacons count] > 0)
    {
        for (ESTBeacon *cBeacon in beacons)
        {
            if ([cBeacon.distance floatValue] < MIN_DISTANCE)
            {
                NSLog(@"Nearby beacon detected.");
                [self matchBeacon:cBeacon];
            }
//            cBeacon.delegate = self;
//            [cBeacon connectToBeacon];
//            NSLog(@"Beacon %@", cBeacon.macAddress);
//            
//            {
//                self.selectedBeacon = cBeacon;
//            }
        }

//
//        NSString *message = [NSString stringWithFormat: @"%d", [beacons count]];
//        [self dontPanic:message];
        
        // Do something after detecting a beacon {self.selectedBeacon}
        [self.tableView reloadData];
    }
}

-(void)beaconConnectionDidSucceeded:(ESTBeacon *)beacon
{
    NSLog(@"Connected!");
}

-(void)beaconDidDisconnect:(ESTBeacon *)beacon withError:(NSError *)error
{
    NSLog(@"Disconnected!");
}

-(void)beaconConnectionDidFail:(ESTBeacon *)beacon withError:(NSError *)error
{
    NSLog(@"Failure!");
}


-(void)matchBeacon:(ESTBeacon *)beacon
{
    NSLog(@"Checking beacon Major:%d Minor:%d", [beacon.major intValue], [beacon.minor intValue]);
    switch ([beacon.major intValue]) {
        case BEACON_1_MAJOR:
            if ([beacon.minor intValue] == BEACON_1_MINOR) {
                if ((!self.isAlerted) && (![self isTimedout:self.timestart1])) {
                    self.timestart1 = CACurrentMediaTime();
                    self.isAlerted = true;
                    [self notify:@"Beacon 1 is nearby"];
                }
            }
            break;
        case BEACON_2_MAJOR:
            if ([beacon.minor intValue] == BEACON_2_MINOR) {
                if ((!self.isAlerted) && (![self isTimedout:self.timestart2])) {
                    self.timestart2 = CACurrentMediaTime();
                    self.isAlerted = true;
                    [self notify:@"Beacon 2 is nearby"];
                }
            }
            break;
        case BEACON_3_MAJOR:
            if ([beacon.minor intValue] == BEACON_3_MINOR) {
                if ((!self.isAlerted) && (![self isTimedout:self.timestart3])) {
                    self.timestart3 = CACurrentMediaTime();
                    self.isAlerted = true;
                    [self notify:@"Beacon 3 is nearby"];
                }
            }
            break;
        default:
            break;
    }
    NSLog(@"Check complete.");
}

-(BOOL)isTimedout:(CFTimeInterval)timestart
{
    NSLog(@"Checking if it is timed out.");
    NSLog(@"Timeout for %f %f", CACurrentMediaTime(), timestart);
    if ((CACurrentMediaTime() - timestart) > MIN_TIMEOUT) {
        return false;
    }
    
    return true;
}

-(void)notify:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notification"
        message:message
        delegate:self
        cancelButtonTitle:@"OK"
        otherButtonTitles:nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    self.isAlerted = false;
}

@end
