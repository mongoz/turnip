//
//  TurnipUser.h
//  turnip
//
//  Created by Per on 2/1/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface TurnipUser : NSObject

@property (nonatomic, copy) NSString *objectId;
@property (nonatomic, copy) NSString *eventId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *birthday;
@property (nonatomic, copy) NSString *facebookId;
@property (nonatomic, copy) UIImage *profileImage;


-(instancetype) initWithPFObject: (PFObject *) object;

@end
