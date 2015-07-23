//
//  SAERatingViewCell.h
//  turnip
//
//  Created by Per on 7/16/15.
//  Copyright (c) 2015 Stupidest App Ever. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SAERatingViewCell;

@protocol SAERatingViewCellDelegate <NSObject>

- (void) ratingViewCellUpVoteTapped:(SAERatingViewCell *) cell;
- (void) ratingViewCellDownVoteTapped:(SAERatingViewCell *) cell;
@end

@interface SAERatingViewCell : UITableViewCell

@property (weak, nonatomic) id <SAERatingViewCellDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIImageView *profileImage;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *rating;
@property (strong, nonatomic) IBOutlet UIButton *downVoteButton;
@property (strong, nonatomic) IBOutlet UIButton *upVoteButton;

- (IBAction)upVoteButton:(id)sender;
- (IBAction)downVoteButton:(id)sender;
@end
