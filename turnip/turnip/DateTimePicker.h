//
//  DateTimePicker.h
//  turnip
//
//  Created by Per on 1/17/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DateTimePicker : UIView

@property (nonatomic, assign, readonly) UIDatePicker *picker;

- (void) setMode: (UIDatePickerMode) mode;
- (void) minimumDate: (NSDate *) min;
- (void) maximumDate: (NSDate *) max;
- (void) addTargetForDoneButton: (id) target action: (SEL) action;
- (void) addTargetForCancelButton: (id) target action: (SEL) action;

@end
