//
//  TeammateTableViewController.h
//  turnip
//
//  Created by Per on 2/24/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TeammateViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSString *eventId;
@property (nonatomic, strong) NSArray *attending;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)addButton:(id)sender;
@end
