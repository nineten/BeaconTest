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

const float BEACON_1_H = 6.52;
const float BEACON_1_L = 3.75;
const float BEACON_2_H = 1.51;
const float BEACON_2_L = 0.67;
const float BEACON_3_H = 6.49;
const float BEACON_3_L = 3.29;

const float BEACON_H_INIT = 0;
const float BEACON_L_INIT = 99;

@interface BeaconListViewController ()

@property NSMutableArray *beacons;
@property (strong, nonatomic) IBOutlet UILabel *regionLabel;
@property (strong, nonatomic) IBOutlet UIButton *recordBtn;
@property (strong, nonatomic) IBOutlet UIButton *showBtn;
@property (nonatomic, strong) ESTBeaconManager* beaconManager;
@property (nonatomic, strong) ESTBeacon* selectedBeacon;
@property BOOL isAlerted;
@property BOOL isInRegion;
@property BOOL isRecording;
@property BOOL hasRecord;

@property float beacon_1_h;
@property float beacon_1_l;
@property float beacon_2_h;
@property float beacon_2_l;
@property float beacon_3_h;
@property float beacon_3_l;

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
    self.isRecording = false;
    self.hasRecord = false;
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
    self.isInRegion = true;
    if([beacons count] > 0) {
        for (ESTBeacon *cBeacon in beacons) {
            if (self.isRecording) {
                self.regionLabel.text = @"Recording.";
                switch ([self matchBeacon:cBeacon]) {
                    case 1:
                        if (([cBeacon.distance floatValue] < self.beacon_1_l) && ([cBeacon.distance floatValue] >= 0.0)) {
                            self.beacon_1_l = [cBeacon.distance floatValue];
                        }
                        if ([cBeacon.distance floatValue] > self.beacon_1_h) {
                            self.beacon_1_h = [cBeacon.distance floatValue];
                        }
                        break;
                    case 2:
                        if (([cBeacon.distance floatValue] < self.beacon_2_l) && ([cBeacon.distance floatValue] >= 0.0)) {
                            self.beacon_2_l = [cBeacon.distance floatValue];
                        }
                        if ([cBeacon.distance floatValue] > self.beacon_2_h) {
                            self.beacon_2_h = [cBeacon.distance floatValue];
                        }
                        break;
                    case 3:
                        if (([cBeacon.distance floatValue] < self.beacon_3_l) && ([cBeacon.distance floatValue] >= 0.0)) {
                            self.beacon_3_l = [cBeacon.distance floatValue];
                        }
                        if ([cBeacon.distance floatValue] > self.beacon_3_h) {
                            self.beacon_3_h = [cBeacon.distance floatValue];
                        }
                        break;
                    default:
                        break;
                }
            }
            else {
                if (self.hasRecord) {
                    if ([self matchBeacon:cBeacon] == 1) {
                        if (([cBeacon.distance floatValue] > self.beacon_1_h)
                            || ([cBeacon.distance floatValue] < self.beacon_1_l)) {
                            self.isInRegion = false;
                            NSLog(@"Beacon 1 not in bound.");
                        }
                    }
                    if ([self matchBeacon:cBeacon] == 2) {
                        if (([cBeacon.distance floatValue] > self.beacon_2_h)
                            || ([cBeacon.distance floatValue] < self.beacon_2_l)) {
                            self.isInRegion = false;
                            NSLog(@"Beacon 2 not in bound.");
                        }
                    }
                    if ([self matchBeacon:cBeacon] == 3) {
                        if (([cBeacon.distance floatValue] > self.beacon_3_h)
                            || ([cBeacon.distance floatValue] < self.beacon_3_l)) {
                            self.isInRegion = false;
                            NSLog(@"Beacon 3 not in bound.");
                        }
                    }
                }
            }
            
        }
        
        if ((!self.isRecording) && (self.hasRecord)) {
            if (self.isInRegion) {
                self.regionLabel.text = @"You are in region.";
                NSLog(@"Is in region");
            }
            else {
                self.regionLabel.text = @"You are not in region.";
                NSLog(@"Is out of region");
            }
            
        }
        
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


-(int)matchBeacon:(ESTBeacon *)beacon
{
    switch ([beacon.major intValue]) {
        case BEACON_1_MAJOR:
            if ([beacon.minor intValue] == BEACON_1_MINOR) {
                return 1;
            }
            break;
        case BEACON_2_MAJOR:
            if ([beacon.minor intValue] == BEACON_2_MINOR) {
                return 2;
            }
            break;
        case BEACON_3_MAJOR:
            if ([beacon.minor intValue] == BEACON_3_MINOR) {
                return 3;
            }
            break;
        default:
            break;
    }
    return 0;
}

-(void)notify:(NSString *)message
{
    if (!self.isAlerted) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notification"
            message:message
            delegate:self
            cancelButtonTitle:@"OK"
            otherButtonTitles:nil];
        [alert show];
    }
    self.isAlerted = true;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    self.isAlerted = false;
}

-(void)initializeRecording {
    self.beacon_1_h = BEACON_H_INIT;
    self.beacon_1_l = BEACON_L_INIT;
    self.beacon_2_h = BEACON_H_INIT;
    self.beacon_2_l = BEACON_L_INIT;
    self.beacon_3_h = BEACON_H_INIT;
    self.beacon_3_l = BEACON_L_INIT;
}


- (IBAction)handleRecordClick:(id)sender {
    NSLog(@"recording");
    self.isRecording = true;
    [self initializeRecording];
}

- (IBAction)handleShowClick:(id)sender {
    NSLog(@"showing");
    self.isRecording = false;
    self.hasRecord = true;
    [self notify:[NSString stringWithFormat:@"Beacon 1\nH: %f\nL: %f\nBeacon 2\nH: %f\nL: %f\nBeacon 3\nH: %f\nL: %f\n",self.beacon_1_h,self.beacon_1_l,self.beacon_2_h,self.beacon_2_l,self.beacon_3_h,self.beacon_3_l]];
}

@end
