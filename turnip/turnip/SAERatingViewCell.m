//
//  SAERatingViewCell.m
//  turnip
//
//  Created by Per on 7/16/15.
//  Copyright (c) 2015 Stupidest App Ever. All rights reserved.
//

#import "SAERatingViewCell.h"

@implementation SAERatingViewCell

- (IBAction)upVoteButton:(id)sender {
    [self.delegate ratingViewCellUpVoteTapped:self];
}

- (IBAction)downVoteButton:(id)sender {
    [self.delegate ratingViewCellDownVoteTapped:self];
}

@end
