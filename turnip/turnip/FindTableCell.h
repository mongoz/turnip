//
//  FindTableCell.h
//  turnip
//
//  Created by Per on 1/14/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>

@interface FindTableCell : UITableViewCell

@property (nonatomic, weak) IBOutlet PFImageView *eventImageView;

@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@end
