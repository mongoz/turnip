//
//  SAEHostAccessoriesViewController.h
//  turnip
//
//  Created by Per on 9/13/15.
//  Copyright (c) 2015 Stupidest App Ever. All rights reserved.
//

#import "SAEHostSingleton.h"
#import <UIKit/UIKit.h>

@interface SAEHostAccessoriesViewController : UIViewController

@property (nonatomic, strong) UIImage *hostImage;
@property (strong, nonatomic) IBOutlet UIImageView *hostImageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;

- (IBAction)backNavigationButtonHandler:(id)sender;
- (IBAction)finishButtonHandler:(id)sender;

- (IBAction)fontButton:(id)sender;
- (IBAction)frameButton:(id)sender;
- (IBAction)textColorButton:(id)sender;
@end
