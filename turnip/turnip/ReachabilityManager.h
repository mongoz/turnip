//
//  ReachabilityManager.h
//  turnip
//
//  Created by Per on 3/13/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Reachability;

@interface ReachabilityManager : NSObject

@property (nonatomic, strong) Reachability *reachability;

#pragma mark - Shared Manager
+ (ReachabilityManager *) sharedManager;

#pragma mark - Class Methods

+ (BOOL) isReachable;
+ (BOOL) isUnreachable;
+ (BOOL) isReachableViaWWAN;
+ (BOOL) isReachableViaWiFi;

@end
