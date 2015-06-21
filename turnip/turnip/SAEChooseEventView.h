//
//  SAEChoosePersonView.h
//  turnip
//
//  Created by Per on 6/18/15.
//  Copyright (c) 2015 Stupidest App Ever. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MDCSwipeToChoose/MDCSwipeToChoose.h>

@class SAESwipeEvent;

@interface SAEChooseEventView : MDCSwipeToChooseView

@property (nonatomic, strong, readonly) SAESwipeEvent *event;

- (instancetype)initWithFrame:(CGRect)frame
                       event:(SAESwipeEvent *)event
                      options:(MDCSwipeToChooseViewOptions *)options;

@end