//
//  MessagingViewController.h
//  turnip
//
//  Created by Per on 3/16/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMBubbleTableViewController.h"

@interface MessagingViewController : AMBubbleTableViewController


@property (nonatomic, strong) NSString *conversationId;
@property (nonatomic, strong) NSArray *user;

@end
