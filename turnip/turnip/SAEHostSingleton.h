//
//  SAEHostSingleton.h
//  turnip
//
//  Created by Per on 9/13/15.
//  Copyright (c) 2015 Stupidest App Ever. All rights reserved.
//

#import <Parse/Parse.h>
#import <Foundation/Foundation.h>

@interface SAEHostSingleton: NSObject

@property (nonatomic, strong) UIImage *eventImage;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *neighbourhood;

@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;

@property (nonatomic, assign) NSNumber *price;

@property (nonatomic, strong) PFUser *host;

@property (nonatomic, assign) BOOL isFree;
@property (nonatomic, assign) BOOL isPrivate;

@property (nonatomic, strong) CLLocation *coordinates;

+ (SAEHostSingleton *) sharedInstance;


@end
