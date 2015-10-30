//
//  SAEEventFeedViewController.h
//  turnip
//
//  Created by Per on 8/4/15.
//  Copyright (c) 2015 Stupidest App Ever. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SAELocationManager.h"
#import <CoreLocation/CoreLocation.h>

@interface SAEEventFeedViewController : UITableViewController <SAELocationMangerDelegate>

@property (nonatomic, strong) CLLocation *currentLocation;

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *imageTapRecognizer;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *profileImageTapRecognizer;

- (IBAction)imageTapRecognizer:(UITapGestureRecognizer *)sender;
- (IBAction)profileImageTapRecognizer:(UITapGestureRecognizer *)sender;

@end
