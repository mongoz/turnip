//
//  AMBubbleTableCell.h
//  AMBubbleTableViewController
//
//  Created by Andrea Mazzini on 30/06/13.
//  Copyright (c) 2013 Andrea Mazzini. All rights reserved.
//

#import "AMBubbleGlobals.h"
#import "AMBubbleFlatAccessoryView.h"

@interface AMBubbleTableCell : UITableViewCell

@property (nonatomic, weak)   NSDictionary* options;
@property (nonatomic, strong) UITextView*	textView;
@property (nonatomic, strong) UIImageView*	imageBackground;
@property (nonatomic, strong) UILabel*		labelUsername;
@property (nonatomic, strong) AMBubbleFlatAccessoryView*		bubbleAccessory;

- (id)initWithOptions:(NSDictionary*)options reuseIdentifier:(NSString *)reuseIdentifier;
- (void)setupCellWithType:(AMBubbleCellType)type withWidth:(float)width andParams:(NSDictionary*)params;

- (UIImageView *)avatarImageView;

@end
