//
//  SAEFindViewController.h
//  Turnip
//
//  Created by Per on 1/4/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <CoreLocation/CoreLocation.h>

@class SAEFindViewController;

@interface SAEFindViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) NSString *neighbourhoodId;
@property (nonatomic, strong) NSString *neighbourhoodName;

@end