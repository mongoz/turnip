	//
//  SAEThrowViewController.h
//  turnip
//
//  Created by Per on 1/4/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MBProgressHUD.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "SAEHostSingleton.h"

@class SAEThrowViewController;

@protocol SAEThrowViewControllerDataSource <NSObject>

- (CLLocation *)currentLocationForThrowViewController:(SAEThrowViewController *) controller;

@end

@interface SAEThrowViewController : UIViewController <UITextViewDelegate,
                                                    UITextFieldDelegate,
                                                    UIScrollViewDelegate>

@property (nonatomic, weak) id<SAEThrowViewControllerDataSource> dataSource;

@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingScrollView  *scrollView;
@property (strong, nonatomic) IBOutlet UIView *contentView;

@property (strong, nonatomic) IBOutlet UITextField *titleField;
@property (strong, nonatomic) IBOutlet UITextView *aboutField;

@property (strong, nonatomic) IBOutlet UITextField *addressField;

@property (strong, nonatomic) IBOutlet UIButton *nextButton;

- (IBAction)nextButtonHandler:(id)sender;

@property (strong, nonatomic) IBOutlet UISwitch *privateSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *freeSwitch;

@property (strong, nonatomic) IBOutlet UITextField *startDate;
@property (strong, nonatomic) IBOutlet UITextField *endDate;

@property (strong, nonatomic) IBOutlet UILabel *cashLabel;
@property (strong, nonatomic) IBOutlet UITextField *cashAmountField;

@end

