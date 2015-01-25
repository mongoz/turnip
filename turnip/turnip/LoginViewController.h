//
//  LoginViewController.h
//  partay
//
//  Created by Per on 1/18/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)facebookLoginButton:(id)sender;

@end
