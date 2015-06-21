//
//  SAESwipeEvent.m
//  turnip
//
//  Created by Per on 6/20/15.
//  Copyright (c) 2015 Stupidest App Ever. All rights reserved.
//

#import "SAESwipeEvent.h"

@implementation SAESwipeEvent

- (instancetype)initWithTitle:(NSString *)title
                       image:(PFFile *)image
                        host:(PFUser *)host
                        eventId:(NSString *)eventId{
    self = [super init];
    if (self) {
        _title = title;
        _image = image;
        _host = host;
        _eventId = eventId;
        }
    return self;
}

@end
