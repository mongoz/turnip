//
//  PMarker.m
//  partay
//
//  Created by Per on 1/15/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "MapMarker.h"
#import <Parse/Parse.h>

@implementation MapMarker


- (BOOL) isEqual:(id)other {
    if (![other isKindOfClass:[MapMarker class]]) {
        return NO;
    }
    MapMarker *otherMarker = (MapMarker *) other;
    
    return [self.objectId isEqual:otherMarker.objectId];
}

- (NSUInteger) hash {
    return [self.objectId hash];
}

@end		
