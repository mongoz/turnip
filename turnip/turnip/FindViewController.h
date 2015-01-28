//
//  FindViewController.h
//  turnip
//
//  Created by Per on 1/4/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <CoreLocation/CoreLocation.h>

@class FindViewController;

// Protocol to get the users currentlocation from the MapViewController.
@protocol FindViewControllerDataSource <NSObject>

- (CLLocation *) currentLocationForFindViewController: (FindViewController *) controller;

@end

@interface FindViewController : PFQueryTableViewController

@property (nonatomic, weak) id<FindViewControllerDataSource> dataSource;

@end