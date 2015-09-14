//
//  SAEAddCardViewController
//  turnip
//
//  Created by Per on 8/17/15.
//  Copyright (c) 2015 Stupidest App Ever. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Stripe/Stripe.h>

@interface SAEAddCardViewController : UIViewController <STPPaymentCardTextFieldDelegate>

@property (nonatomic) STPPaymentCardTextField *paymentTextField;
@property (strong, nonatomic) IBOutlet UIButton *saveButton;

@property (nonatomic, assign) BOOL newCustomer;

- (IBAction)backNavigation:(id)sender;
- (IBAction)saveButton:(id)sender;
@end
