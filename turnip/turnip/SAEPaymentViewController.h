//
//  SAEPaymentViewController.h
//  turnip
//
//  Created by Per on 8/18/15.
//  Copyright (c) 2015 Stupidest App Ever. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SAEPaymentViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
- (IBAction)newCreditCardButton:(id)sender;
- (IBAction)backNavigation:(id)sender;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end
