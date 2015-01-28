//
//  MapViewController.h
//  turnip
//
//  Created by Per on 1/4/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoogleMaps/GoogleMaps.h"
#import <CoreLocation/CoreLocation.h>

@interface MapViewController : UIViewController <GMSMapViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UIButton *updateButton;

- (IBAction)updateButtonHandler:(id)sender;

@end

