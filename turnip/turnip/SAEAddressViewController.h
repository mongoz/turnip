//
//  SAEAddressViewController.h
//  turnip
//
//  Created by Per on 6/2/15.
//  Copyright (c) 2015 Stupidest App Ever. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SAEAddressViewController : UIViewController  <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (weak, nonatomic) NSTimer *searchDelayer;
@end
