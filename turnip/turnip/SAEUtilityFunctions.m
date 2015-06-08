//
//  SAEUtilityFunctions.m
//  turnip
//
//  Created by Per on 5/31/15.
//  Copyright (c) 2015 Stupidest App Ever. All rights reserved.
//

#import "SAEUtilityFunctions.h"

@implementation SAEUtilityFunctions

+ (NSString *) convertDate: (NSDate *) date {
    
    NSString *dateString = nil;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *currentLocale = [NSLocale currentLocale];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    NSUInteger units = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:units fromDate:[NSDate date]];
  // comps.day = comps.day + 1;
    NSDate *tomorrowMidnight = [[NSCalendar currentCalendar] dateFromComponents:comps];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [dateFormatter setLocale:currentLocale];
    
    NSString *eventDate = [dateFormatter stringFromDate:date];
    
    NSDate *eventDay = [dateFormatter dateFromString:eventDate];
    
    NSInteger differenceInDays =
    [calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSEraCalendarUnit forDate: eventDay] -
    [calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSEraCalendarUnit forDate:tomorrowMidnight];
    
    switch (differenceInDays) {
        case -1:
        case 0:
        case 1:
            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
            [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
            
            [dateFormatter setLocale:currentLocale];
            
            [dateFormatter setDoesRelativeDateFormatting:YES];
            
            dateString = [dateFormatter stringFromDate:date];
            break;
        default: {
            // Set the date components you want
            NSString *dateComponents = @"EEEEMMMMd, h:mm a";
            
            // The components will be reordered according to the locale
            NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:dateComponents options:0 locale:currentLocale];
            
            [dateFormatter setDateFormat:dateFormat];
            
            dateString = [dateFormatter stringFromDate:date];
            
            break;
        }
    }
    
    return dateString;
}

+ (NSInteger) calculateAge: (NSString *) birthday {
    
    NSDate *todayDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    int time = [todayDate timeIntervalSinceDate:[dateFormatter dateFromString:birthday]];
    int allDays = (((time/60)/60)/24);
    int days = allDays%365;
    int years = (allDays-days)/365;
    
    return  years;
}

+ (UIImage *)imageResize :(UIImage*)img andResizeTo:(CGSize)newSize
{
    CGFloat scale = [[UIScreen mainScreen]scale];
    /*You can remove the below comment if you dont want to scale the image in retina   device .Dont forget to comment UIGraphicsBeginImageContextWithOptions*/
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, scale);
    [img drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
