//
//  TeammateTableViewController.h
//  turnip
//
//  Created by Per on 2/24/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface TeammateTableViewController : PFQueryTableViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSString *eventId;
@property (nonatomic, strong) NSArray *accepted;

@end
