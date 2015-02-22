//
//  DetailSidebarTableViewController.h
//  turnip
//
//  Created by Per on 2/18/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailSidebarTableViewController;

@interface DetailSidebarTableViewController : UITableViewController <UIAlertViewDelegate>

@property (nonatomic) NSString *eventId;

@property (nonatomic, strong) NSArray *event;

@end
