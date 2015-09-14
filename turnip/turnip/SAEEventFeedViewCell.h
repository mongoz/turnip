//
//  SAEEventFeedViewCell.h
//  turnip
//
//  Created by Per on 8/4/15.
//  Copyright (c) 2015 Stupidest App Ever. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>

@class SAEEventFeedViewCell;

@protocol SAEEventFeedViewCellDelegate <NSObject>

- (void) eventFeedViewCellAttendButton:(SAEEventFeedViewCell *) cell;

@end

@interface SAEEventFeedViewCell : UITableViewCell

@property (weak, nonatomic) id <SAEEventFeedViewCellDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIImageView *profileImage;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *attendingLabel;

@property (strong, nonatomic) IBOutlet PFImageView *eventImage;
@property (strong, nonatomic) IBOutlet UIButton *attendButton;

- (IBAction)attendButton:(id)sender;
@end
