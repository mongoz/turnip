//
//  SAEDetailsViewController.h
//  turnip
//
//  Created by Per on 9/17/15.
//  Copyright (c) 2015 Stupidest App Ever. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SAEEvent.h"

@interface SAEDetailsViewController : UIViewController

@property (nonatomic, strong) SAEEvent *event;

@property (strong, nonatomic) IBOutlet UIButton *messageButton;
@property (strong, nonatomic) IBOutlet UIButton *attendButton;

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UILabel *hostLabel;
@property (strong, nonatomic) IBOutlet UIButton *attendingButton;

- (IBAction)attendingButton:(id)sender;
- (IBAction)messageButton:(id)sender;
- (IBAction)attendButton:(id)sender;
- (IBAction)backNavigationButton:(id)sender;
@end
