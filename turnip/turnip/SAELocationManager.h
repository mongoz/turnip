//
//  SAELocationManager.h
//  turnip
//
//  Created by Per on 6/17/15.
//  Copyright (c) 2015 Stupidest App Ever. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol SAELocationMangerDelegate

- (void) locationManagerDidUpdateLocation: (CLLocation *) location;

@end

@interface SAELocationManager : NSObject <CLLocationManagerDelegate>

+ (SAELocationManager *) sharedInstance;
- (void) addLocationManagerDelegate:(id <SAELocationMangerDelegate>) delegate;
- (void) removeLocationManagerDelegate:(id <SAELocationMangerDelegate>) delegate;
@end
