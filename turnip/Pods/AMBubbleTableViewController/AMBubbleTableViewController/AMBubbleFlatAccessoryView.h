//
//  AMBubbleFlatAccessoryView.h
//  AMBubbleTableViewController
//
//  Created by Andrea Mazzini on 02/08/13.
//  Copyright (c) 2013 Andrea Mazzini. All rights reserved.
//

#import "AMBubbleGlobals.h"

@interface AMBubbleFlatAccessoryView : UIView<AMBubbleAccessory>

@property (nonatomic, strong) UIImageView*	imageAvatar;
@property (nonatomic, weak)   NSDictionary* options;
@property (nonatomic, strong) UILabel*		labelTimestamp;
@property (nonatomic, strong) UIImageView*	imageCheck;

@end
