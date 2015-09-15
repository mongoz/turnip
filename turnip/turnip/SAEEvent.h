//
//  SAEEvent.h
//  turnip
//
//  Created by Per on 9/13/15.
//  Copyright (c) 2015 Stupidest App Ever. All rights reserved.
//

#import <Parse/Parse.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface SAEEvent : NSObject

@property (nonatomic, strong) UIImage *eventImage;

@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *objectId;
@property (nonatomic, copy, readonly) NSString *text;
@property (nonatomic, copy, readonly) NSString *address;

@property (nonatomic, copy, readonly) NSDate *date;
@property (nonatomic, copy, readonly) NSDate *endDate;

@property (nonatomic, assign) NSInteger price;

@property (nonatomic, strong) PFUser *host;
@property (nonatomic, strong) NSArray *attendees;

@property (nonatomic, assign) BOOL *isFree;
@property (nonatomic, assign) BOOL *isPrivate;
@property (nonatomic, strong) PFObject *neighbourhood;


- (instancetype) initWithImage:(UIImage *) eventImage
                         title:(NSString *) title
                      objectId:(NSString *) objectId
                          date: (NSDate *) date
                          host:(PFUser *) host
                     attendees:(NSArray *) attendees
                          text:(NSString *) text
                       address:(NSString *) address
                        isFree:(BOOL *) isFree
                     isPrivate:(BOOL *) isPrivate
                 neighbourhood:(PFObject *) neighbourhood;



- (instancetype) initWithImage:(UIImage *) eventImage
                      objectId:(NSString *) objectId
                         title:(NSString *) title
                          date:(NSDate *) date
                          host:(PFUser *) host
                     attendees:(NSArray *) attendees;

- (instancetype) initWithTitle:(NSString *) title
                          text:(NSString *) text
                       address:(NSString *) address
                         price:(NSInteger) price
                          date:(NSDate *) date
                       endDate:(NSDate *) endDate
                     isPrivate:(BOOL *) isPrivate
                        isFree:(BOOL *) isFree
                 neighbourhood:(PFObject *) neighbourhood
                          host:(PFUser *) host;


@end
