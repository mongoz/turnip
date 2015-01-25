//
//  Partay.m
//  partay
//
//  Created by Per on 1/11/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "TurnipEvent.h"
#import "Constants.h"

@interface TurnipEvent ()

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy) NSString *objectId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *text;

@property (nonatomic, strong) PFObject *object;
@property (nonatomic, strong) PFUser *user;
@end

@implementation TurnipEvent

#pragma mark -
#pragma mark Init

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate
                          andTitle:(NSString *)title
                           andText:(NSString *)text
                             andId:(NSString *)objectId {
    self = [super init];
    
    if(self) {
        self.coordinate = coordinate;
        self.title = title;
        self.text = text;
        self.objectId = objectId;
    }
    return self;
}

- (instancetype)initWithPFObject:(PFObject *)object {
    //If we can not find the object fetch it
    [object fetchIfNeeded];
    
    PFGeoPoint *geoPoint = object[PartayParsePostLocationKey];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
    
    NSString *objectId = [object objectId];
    NSString *title = object[PartayParsePostTitleKey];
    NSString *text = object[PartayParsePostTextKey];
    
    self = [self initWithCoordinate:coordinate andTitle:title andText:text andId:objectId];
    if(self) {
        self.object = object;
        //self.user = object[PartayParsePostUserKey];
    }
    return self;
}

- (BOOL) isEqual:(id)object {
    
    TurnipEvent *event = (TurnipEvent *) object;
    
    if (event.object && self.object) {
        // We have a PFObject inside the partay, use that instead.
        return [event.object.objectId isEqualToString:self.object.objectId];
    }
    
    // Fallback to properties
    return ([event.title isEqualToString:self.title] &&
            [event.text isEqualToString:self.text] &&
            event.coordinate.latitude == self.coordinate.latitude &&
            event.coordinate.longitude == self.coordinate.longitude);
}

@end

