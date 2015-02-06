//
//  NavigationViewController.h
//  turnip
//
//  Created by Per on 2/5/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavigationViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end
