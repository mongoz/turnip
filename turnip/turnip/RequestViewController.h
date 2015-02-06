//
//  RequestViewController.h
//  turnip
//
//  Created by Per on 2/3/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCSwipeTableViewCell.h"

@interface RequestViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MCSwipeTableViewCellDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;


@end
