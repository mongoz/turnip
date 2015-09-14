//
//  SAEAddCardViewController.m
//  turnip
//
//  Created by Per on 8/17/15.
//  Copyright (c) 2015 Stupidest App Ever. All rights reserved.
//

#import "SAEAddCardViewController.h"
#import "ProfileViewController.h"
#import <Parse/Parse.h>

#define  STRIPE_TEST_PUBLIC_KEY @"pk_test_DbMmTlz56j1vq6YhfoCZiXBS "

@interface SAEAddCardViewController ()


@end

@implementation SAEAddCardViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Add Card";
    
    self.paymentTextField = [[STPPaymentCardTextField alloc] initWithFrame:CGRectMake(15, 70, CGRectGetWidth(self.view.frame) - 33, 44)];;
    self.paymentTextField.delegate = self;
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleDefault;
    numberToolbar.items = @[[[UIBarButtonItem alloc]initWithTitle:@"<" style:UIBarButtonItemStyleBordered target:self action:@selector(backNumberPad)],
                            [[UIBarButtonItem alloc]initWithTitle:@">" style:UIBarButtonItemStyleBordered target:self action:@selector(nextNumberPad)],
                            [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)]];
    [numberToolbar sizeToFit];
    
    self.paymentTextField.inputAccessoryView = numberToolbar;
    
    [self.view addSubview:self.paymentTextField];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeResponder:)];
    
    [self.view addGestureRecognizer:tapGesture];
    
}

- (void)backNumberPad {
    NSLog(@"back");
}

- (void) nextNumberPad {
    NSLog(@"next");
}

- (void)doneWithNumberPad {
    [self.paymentTextField resignFirstResponder];
}

- (void) removeResponder:(UITapGestureRecognizer *) sender {
    [self.paymentTextField resignFirstResponder];
}


- (void)paymentCardTextFieldDidChange:(STPPaymentCardTextField *)textField {
    // Toggle navigation, for example
    self.saveButton.enabled = textField.isValid;
}

- (void)handleStripeError:(NSError *) error {
    
    if ([error.domain isEqualToString:@"StripeDomain"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Please try again"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    
    self.saveButton.enabled = YES;
}

- (IBAction)saveButton:(id)sender {
    
    if (![self.paymentTextField isValid]) {
        return;
    }
    
    self.saveButton.enabled = NO;
 
    STPCard *card = [[STPCard alloc] init];
    card.number = self.paymentTextField.card.number;
    card.expMonth = self.paymentTextField.card.expMonth;
    card.expYear = self.paymentTextField.card.expYear;
    card.cvc = self.paymentTextField.card.cvc;
    
    [[STPAPIClient sharedClient] createTokenWithCard:card
                                          completion:^(STPToken *token, NSError *error) {
                                              if (error) {
                                                  [self handleStripeError:error];
                                              } else {
                                                  NSLog(@"token: %@", token);
                                                  
                                                  NSDictionary *customerInfo = @{
                                                                                @"cardToken": token.tokenId,
                                                                                @"email": [[PFUser currentUser] objectForKey:@"email"],
                                                                                @"customer": [NSString stringWithFormat:@"%@ %@",
                                                                                              [[PFUser currentUser] objectForKey:@"firstName"],
                                                                                              [[PFUser currentUser] objectForKey:@"lastName"]]
                                                                                };
                                                  if(self.newCustomer) {
                                                      [PFCloud callFunctionInBackground:@"createCustomer"
                                                                         withParameters:customerInfo
                                                                                  block:^(id object, NSError *error) {
                                                                                      if (!error) {
                                                                                          NSLog(@"object: %@", object);
                                                                                      } else {
                                                                                          self.saveButton.enabled = YES;
                                                                                          [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                                                                                      message:[[error userInfo] objectForKey:@"error"]
                                                                                                                     delegate:nil
                                                                                                            cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                                                                            otherButtonTitles:nil] show];
                                                                                      }
                                                                                  }];
                                                  } else {
                                                      
                                                  }
                                              }
                                          }];

}
- (IBAction)backNavigation:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
