//
//  SAEUtilityFunctions.h
//  turnip
//
//  Created by Per on 5/31/15.
//  Copyright (c) 2015 Stupidest App Ever. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SAEUtilityFunctions : NSObject

+ (NSString *) convertDate: (NSDate *) date;
+ (NSInteger) calculateAge: (NSString *) birthday;
+ (UIImage *)imageResize :(UIImage*)img andResizeTo:(CGSize)newSize;

@end
