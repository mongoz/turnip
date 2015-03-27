//
//  MessagingViewController.h
//  turnip
//
//  Created by Per on 3/16/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessagingViewController : UIViewController <UITextFieldDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSString *conversationId;
@property (nonatomic, strong) NSArray *user;

@property (strong, nonatomic) IBOutlet UITextField *messageField;

- (IBAction)sendButton:(id)sender;
@end
