//
//  ReachabilityManager.m
//  turnip
//
//  Created by Per on 3/13/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "ReachabilityManager.h"

#import "Reachability.h"


@implementation ReachabilityManager

+(ReachabilityManager *) sharedManager {
    static ReachabilityManager *_sharedManager = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

- (void) dealloc {
    if (self.reachability) {
        [self.reachability stopNotifier];
    }
}

#pragma mark - Class Methods

+ (BOOL) isReachable {
    return [[[ReachabilityManager sharedManager] reachability] isReachable];
}
+ (BOOL) isUnreachable {
    return [[[ReachabilityManager sharedManager] reachability] isReachable];
}
+ (BOOL) isReachableViaWWAN {
    return [[[ReachabilityManager sharedManager] reachability] isReachableViaWWAN];
}
+ (BOOL) isReachableViaWiFi {
    return [[[ReachabilityManager sharedManager] reachability] isReachableViaWiFi];
}

#pragma mark - Initialization
- (id) init {
    self= [super init];
    
    if (self) {
        //Init reachability;
        self.reachability = [Reachability reachabilityWithHostName:@"www.facebook.com"];
    
        //Start Monitoring internet connection
        [self.reachability startNotifier];
    }
    return self;
}

@end
