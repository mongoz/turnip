//
//  SAEHostSingleton.m
//  turnip
//
//  Created by Per on 9/13/15.
//  Copyright (c) 2015 Stupidest App Ever. All rights reserved.
//

#import "SAEHostSingleton.h"

@interface SAEHostSingleton ()

@end

@implementation SAEHostSingleton

+(SAEHostSingleton *) sharedInstance {
    static SAEHostSingleton *sharedInstance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


@end
