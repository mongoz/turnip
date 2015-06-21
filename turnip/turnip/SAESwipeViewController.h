//
//  SAESwipeViewController.h
//  turnip
//
//  Created by Per on 6/9/15.
//  Copyright (c) 2015 Stupidest App Ever. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SAELocationManager.h"
#import <MDCSwipeToChoose/MDCSwipeToChoose.h>
#import <CoreLocation/CoreLocation.h>
#import "SAEChooseEventView.h"
#import "SAESwipeEvent.h"

@interface SAESwipeViewController : UIViewController <SAELocationMangerDelegate, MDCSwipeToChooseDelegate>

@property (nonatomic, strong) CLLocation *currentLocation;
@property (strong, nonatomic) IBOutlet UILabel *backgroundLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UIButton *ignoreButton;
@property (strong, nonatomic) IBOutlet UIButton *requestButton;
- (IBAction)ignoreButton:(id)sender;
- (IBAction)requestButton:(id)sender;

@property (nonatomic, strong) SAESwipeEvent *currentEvent;
@property (nonatomic, strong) SAEChooseEventView *frontCardView;
@property (nonatomic, strong) SAEChooseEventView *backCardView;

@end
