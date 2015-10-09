//
//  SAEHostAccessoriesViewController.h
//  turnip
//
//  Created by Per on 9/13/15.
//  Copyright (c) 2015 Stupidest App Ever. All rights reserved.
//

#import "ISColorWheel.h"
#import "MBProgressHUD.h"
#import "SAEHostSingleton.h"
#import <UIKit/UIKit.h>

@interface SAEHostAccessoriesViewController : UIViewController <ISColorWheelDelegate, MBProgressHUDDelegate>


@property (strong, nonatomic) MBProgressHUD * HUD;
@property (strong, nonatomic) ISColorWheel *colorWheel;
@property (strong, nonatomic) UISlider *brightnessSlider;

@property (strong, nonatomic) IBOutlet UIView *detailsView;
@property (strong, nonatomic) IBOutlet UIView *buttonView;
@property (strong, nonatomic) IBOutlet UIView *shareView;

@property (nonatomic, strong) UIImage *hostImage;
@property (strong, nonatomic) IBOutlet UIImageView *hostImageView;
@property (strong, nonatomic) IBOutlet UIImageView *borderImageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;

- (IBAction)shareInstagramButton:(id)sender;
- (IBAction)shareFacebookButton:(id)sender;
- (IBAction)shareTwitterButton:(id)sender;
- (IBAction)shareButton:(id)sender;
- (IBAction)doneShareButton:(id)sender;

- (IBAction)backNavigationButtonHandler:(id)sender;
- (IBAction)finishButtonHandler:(id)sender;

- (IBAction)frameColorButton:(id)sender;
- (IBAction)fontButton:(id)sender;
- (IBAction)frameButton:(id)sender;
- (IBAction)textColorButton:(id)sender;
@end

