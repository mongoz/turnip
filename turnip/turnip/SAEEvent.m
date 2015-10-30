//
//  SAEEvent.m
//  turnip
//
//  Created by Per on 9/13/15.
//  Copyright (c) 2015 Stupidest App Ever. All rights reserved.
//

#import "SAEEvent.h"

@interface SAEEvent ()

@property (nonatomic, copy) NSString *objectId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSDate *date;

@end

@implementation SAEEvent


- (instancetype) initWithImage:(UIImage *)eventImage
                         title:(NSString *)title
                      objectId:(NSString *)objectId
                          date:(NSDate *)date
                          host:(PFUser *)host
                     attendees:(NSArray *)attendees
                          text:(NSString *)text
                       address:(NSString *)address
                        isFree:(BOOL)isFree
                     isPrivate:(BOOL)isPrivate
                 neighbourhood:(PFObject *)neighbourhood {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (instancetype) initWithImage:(PFFile *)eventImage
                      objectId:(NSString *)objectId
                         title:(NSString *)title
                          date:(NSDate *)date
                          host:(PFUser *)host
                     attendees:(NSArray *)attendees
                     isPrivate:(BOOL)isPrivate{
    self = [super init];
    
    if (self) {
        self.eventImage = eventImage;
        self.objectId = objectId;
        self.title = title;
        self.date = date;
        self.host = host;
        self.attendees = attendees;
        self.isPrivate = isPrivate;
    }
    return self;
}

- (instancetype) initWithTitle:(NSString *)title
                          text:(NSString *)text
                       address:(NSString *)address
                         price:(NSInteger)price
                          date:(NSDate *)date
                       endDate:(NSDate *)endDate
                     isPrivate:(BOOL)isPrivate
                        isFree:(BOOL)isFree
                 neighbourhood:(PFObject *)neighbourhood
                          host:(PFUser *)host {
    self = [super init];
    
    if (self) {
        _title = title;
        _text = text;
        _address = address;
        _price = price;
        _date = date;
        _endDate = endDate;
        _isPrivate = isPrivate;
        _isFree = isFree;
        _neighbourhood = neighbourhood;
        _host = host;
    }
    
    return self;
}

@end
