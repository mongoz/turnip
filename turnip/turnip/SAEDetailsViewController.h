//
//  SAEDetailsViewController.h
//  turnip
//
//  Created by Per on 9/17/15.
//  Copyright (c) 2015 Stupidest App Ever. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SAEDetailsViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *messageButton;
@property (strong, nonatomic) IBOutlet UIButton *attendButton;

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UILabel *hostLabel;
@property (strong, nonatomic) IBOutlet UILabel *goingLabel;
@property (strong, nonatomic) IBOutlet UILabel *friendsLabel;

- (IBAction)messageButton:(id)sender;
- (IBAction)attendButton:(id)sender;
- (IBAction)backNavigationButton:(id)sender;
@end
