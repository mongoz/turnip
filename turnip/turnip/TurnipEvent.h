//
//  TurnipEvent.h
//  turnip
//
//  Created by Per on 1/11/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface TurnipEvent : NSObject

@property (nonatomic, assign, readonly) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy, readonly) NSString *objectId;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *text;

@property (nonatomic, strong, readonly) PFObject *object;
@property (nonatomic, strong, readonly) PFUser *user;


- (instancetype)initWithCoordinate:(CLLocationCoordinate2D) coordinate
                          andTitle:(NSString *)title
                           andText:(NSString *)text
                             andId:(NSString *) objectId;

- (instancetype)initWithPFObject: (PFObject *)object;


@end
