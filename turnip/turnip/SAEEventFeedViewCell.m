//
//  SAEEventFeedViewCell.m
//  turnip
//
//  Created by Per on 8/4/15.
//  Copyright (c) 2015 Stupidest App Ever. All rights reserved.
//

#import "SAEEventFeedViewCell.h"

@implementation SAEEventFeedViewCell

- (IBAction)attendingButton:(id)sender {
    [self.delegate eventFeedViewCellAttendingButton:self];
}

- (IBAction)attendButton:(id)sender {
    [self.delegate eventFeedViewCellAttendButton:self];
}

@end
