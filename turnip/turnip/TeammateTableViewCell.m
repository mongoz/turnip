//
//  TeammateTableViewCell.m
//  turnip
//
//  Created by Per on 2/25/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "TeammateTableViewCell.h"

@implementation TeammateTableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)checkButtonHandler:(id)sender {
    [self.checkButton setImage:[UIImage imageNamed: @"teammate-pressed"] forState:UIControlStateNormal];
    
    NSLog(@"pressed");
}
@end
