//
//  LoginViewController.h
//  turnip
//
//  Created by Per on 1/18/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *facebookLoginButton;
@property (strong, nonatomic) IBOutlet UILabel *connectionLabel;

- (IBAction)facebookLoginButton:(id)sender;

@end
