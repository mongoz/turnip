//
//  LoginViewController.h
//  turnip
//
//  Created by Per on 1/18/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SAELoginViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *facebookLoginButton;
@property (strong, nonatomic) IBOutlet UILabel *connectionLabel;

- (IBAction)facebookLoginButton:(id)sender;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@end
