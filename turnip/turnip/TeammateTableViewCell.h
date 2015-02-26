//
//  TeammateTableViewCell.h
//  turnip
//
//  Created by Per on 2/25/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TeammateTableViewCell;

@protocol TeammateCellDelegate <NSObject>

- (void) teammateCellAddWasTapped:(TeammateTableViewCell *) cell;

@end

@interface TeammateTableViewCell : UITableViewCell

@property (weak, nonatomic) id <TeammateCellDelegate> delegate;

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *profileImage;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *imageSpinner;

@property (strong, nonatomic) IBOutlet UIButton *checkButton;

- (IBAction)checkButtonHandler:(id)sender;
@end
  