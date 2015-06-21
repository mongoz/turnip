//
//  SAESwipeEvent.h
//  turnip
//
//  Created by Per on 6/20/15.
//  Copyright (c) 2015 Stupidest App Ever. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <ParseUI/ParseUI.h>

@interface SAESwipeEvent : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) PFFile *image;
@property (nonatomic, strong) PFUser *host;
@property (nonatomic, assign) NSUInteger distance;
@property (nonatomic, assign) NSUInteger numberOfFriends;
@property (nonatomic, strong) NSString *eventId;

- (instancetype)initWithTitle:(NSString *)title
                       image:(PFFile *)image
                        host:(PFUser *) host
                     eventId:(NSString *) eventId;

@end
