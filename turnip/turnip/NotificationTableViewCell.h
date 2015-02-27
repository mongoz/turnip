//
//  NotificationTableViewCell.h
//  turnip
//
//  Created by Per on 2/27/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>

@interface NotificationTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet PFImageView *noteImageView;
@property (strong, nonatomic) IBOutlet UILabel *noteTextLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *imageSpinner;

@end
