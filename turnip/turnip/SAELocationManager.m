//
//  SAELocationManager.m
//  turnip
//
//  Created by Per on 6/17/15.
//  Copyright (c) 2015 Stupidest App Ever. All rights reserved.
//

#import "SAELocationManager.h"

@interface SAELocationManager ()

@property (strong, nonatomic) CLLocationManager *manager;
@property (strong, nonatomic) NSMutableArray *observers;

@end

@implementation SAELocationManager
static int errorCount = 0;
#define MAX_LOCATION_ERROR 3


+(SAELocationManager *) sharedInstance {
    static SAELocationManager *sharedInstance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype) init {
    self = [super init];
    if(self) {
        
        //Must check authorizationStatus before initiating a CLLocationManager
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        if (status == kCLAuthorizationStatusRestricted && status == kCLAuthorizationStatusDenied) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location Error" message:@"To use this app you need to allow it to use your current Location." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alertView show];

        } else {
            _manager = [[CLLocationManager alloc] init];
            _manager.delegate = self;
            _manager.desiredAccuracy = kCLLocationAccuracyBest;
            _manager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
        }
        if (status == kCLAuthorizationStatusNotDetermined) {
            //Must check if selector exists before messaging it
            if ([_manager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [_manager requestWhenInUseAuthorization];
            }
        }
        
        _observers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) addLocationManagerDelegate:(id<SAELocationMangerDelegate>)delegate {
    if (![self.observers containsObject:delegate]) {
        [self.observers addObject:delegate];
    }
    [self.manager startUpdatingLocation];
}

- (void) removeLocationManagerDelegate:(id<SAELocationMangerDelegate>)delegate {
    if ([self.observers containsObject:delegate]) {
        [self.observers removeObject:delegate];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self.manager stopUpdatingLocation];
    for(id<SAELocationMangerDelegate> observer in self.observers) {
        if (observer) {
            [observer locationManagerDidUpdateLocation:[locations lastObject]];
        }
    }
}

-(void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    errorCount += 1;
    if(errorCount >= MAX_LOCATION_ERROR) {
        [self.manager stopUpdatingLocation];
        errorCount = 0;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];
    }
}


@end
