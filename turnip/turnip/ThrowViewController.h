	//
//  ThrowViewController.h
//  turnip
//
//  Created by Per on 1/4/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MBProgressHUD.h"

@class ThrowViewController;

@protocol ThrowViewControllerDataSource <NSObject>

- (CLLocation *)currentLocationForThrowViewController:(ThrowViewController *) controller;

@end

@interface ThrowViewController : UIViewController <UITextViewDelegate,
                                                    UITextFieldDelegate>

@property (nonatomic, weak) id<ThrowViewControllerDataSource> dataSource;

@property (strong, nonatomic) IBOutlet UITextField *titleField;
@property (strong, nonatomic) IBOutlet UITextView *aboutField;
@property (strong, nonatomic) IBOutlet UITextField *locationField;

@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) IBOutlet UIButton *nextButton;

- (IBAction)backButtonHandler:(id)sender;
- (IBAction)nextButtonHandler:(id)sender;

@property (strong, nonatomic) IBOutlet UISwitch *privateSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *freeSwitch;


@property (strong, nonatomic) IBOutlet UILabel *cashLabel;
@property (strong, nonatomic) IBOutlet UITextField *cashAmountField;

@end

