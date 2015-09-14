//
//  SAEStripeCard.m
//  turnip
//
//  Created by Per on 8/19/15.
//  Copyright (c) 2015 Stupidest App Ever. All rights reserved.
//

#import "SAEStripeCard.h"

@implementation SAEStripeCard

- (instancetype) initWithCardId:(NSString *)cardId
                         object:(NSString *)object
                          last4:(NSInteger)last4
                          brand:(NSString *)brand
                        country:(NSString *)country
                    defaultCard:(BOOL)defaultCard {
    
    self = [super init];
    if (self) {
        self.cardId = cardId;
        self.object = object;
        self.last4 = last4;
        self.brand = brand;
        self.country = country;
        self.defaultCard = defaultCard;
    }
    return self;
    
}

- (instancetype) initWithCardId:(NSString *)cardId
                         object:(NSString *)object
                          last4:(NSNumber *)last4
                          brand:(NSString *)brand
                        country:(NSString *)country
                        funding:(NSString *)funding
                      ext_month:(NSNumber *)exp_month
                       exp_year:(NSNumber *)exp_year {
    
    self = [super init];
    if (self) {
        
    }
    return self;
}

@end
