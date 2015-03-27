//
//  VerificationViewController.h
//  turnip
//
//  Created by Per on 3/27/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VerificationViewController : UIViewController

- (IBAction)acceptButton:(id)sender;
- (IBAction)cancelButton:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *codeField;
@end
