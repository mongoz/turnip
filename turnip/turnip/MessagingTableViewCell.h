//
//  MessagingTableViewCell.h
//  turnip
//
//  Created by Per on 3/26/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessagingTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *otherImage;
@property (strong, nonatomic) IBOutlet UILabel *otherText;
@property (strong, nonatomic) IBOutlet UIImageView *outgoingImage;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;


@end
