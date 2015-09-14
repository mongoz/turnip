//
//  SAEStripeCard.h
//  turnip
//
//  Created by Per on 8/19/15.
//  Copyright (c) 2015 Stupidest App Ever. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SAEStripeCard : NSObject

@property (nonatomic, copy) NSString *object;
@property (nonatomic, copy) NSString *brand;
@property (nonatomic, copy) NSString *funding;
@property (nonatomic, copy) NSString *country;
@property (nonatomic, copy) NSString *cardId;
@property (nonatomic, assign) BOOL defaultCard;
@property (nonatomic, assign) NSInteger last4;
@property (nonatomic, assign) NSInteger exp_month;
@property (nonatomic, assign) NSInteger exp_year;
@property (nonatomic, assign) UIImage *cardImage;

- (instancetype) initWithCardId:(NSString *) cardId
                         object:(NSString *) object
                          last4:(NSInteger) last4
                          brand:(NSString *) brand
                        country:(NSString *) country
                    defaultCard:(BOOL) defaultCard;

- (instancetype) initWithCardId:(NSString *) cardId
                         object:(NSString *) object
                          last4:(NSNumber *) last4
                          brand:(NSString *) brand
                        country:(NSString *) country
                        funding:(NSString *) funding
                      ext_month:(NSNumber *) exp_month
                       exp_year:(NSNumber *) exp_year;



@end
