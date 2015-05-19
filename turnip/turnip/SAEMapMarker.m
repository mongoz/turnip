//
//  SAEMapMarker.m
//  Turnip
//
//  Created by Per on 1/15/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "SAEMapMarker.h"
#import <Parse/Parse.h>

@implementation SAEMapMarker


- (BOOL) isEqual:(id)other {
    if (![other isKindOfClass:[SAEMapMarker class]]) {
        return NO;
    }
    SAEMapMarker *otherMarker = (SAEMapMarker *) other;
    
    return [self.objectId isEqual:otherMarker.objectId];
}

- (NSUInteger) hash {
    return [self.objectId hash];
}

@end		
