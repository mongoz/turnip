//
//  SAEMapViewController.h
//  Turnip
//
//  Created by Per on 1/4/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoogleMaps/GoogleMaps.h"
#import <CoreLocation/CoreLocation.h>
#import "SAELocationManager.h"

@interface SAEMapViewController : UIViewController <GMSMapViewDelegate, SAELocationMangerDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet UIButton *updateButton;

- (IBAction)updateButtonHandler:(id)sender;



@end

