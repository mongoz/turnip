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
                                                    UITextFieldDelegate,
                                                    UIActionSheetDelegate,
                                                    UINavigationControllerDelegate,
                                                    UIImagePickerControllerDelegate,
                                                    MBProgressHUDDelegate>

@property (strong, nonatomic) IBOutlet UITextField *dateInputField;
@property (strong, nonatomic) IBOutlet UITextField *endTimeDate;

@property (nonatomic, weak) id<ThrowViewControllerDataSource> dataSource;

@property (strong, nonatomic) IBOutlet UIImageView *imageOne;
@property (strong, nonatomic) IBOutlet UIImageView *imageTwo;
@property (strong, nonatomic) IBOutlet UIImageView *imageThree;

- (IBAction)imageOneTapHandler:(UITapGestureRecognizer *)sender;
- (IBAction)imageTwoTapHandler:(UITapGestureRecognizer *)sender;
- (IBAction)imageThreeTapHandler:(UITapGestureRecognizer *)sender;

@property (strong, nonatomic) IBOutlet UITextField *titleField;
@property (strong, nonatomic) IBOutlet UITextView *aboutField;
@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) IBOutlet UIButton *createButton;
@property (strong, nonatomic) IBOutlet UIButton *deleteButton;

@property (strong, nonatomic) MBProgressHUD * HUD;

- (IBAction)backButtonHandler:(id)sender;
- (IBAction)createButtonHandler:(id)sender;
- (IBAction)deleteButtonHandler:(id)sender;

@property (strong, nonatomic) IBOutlet UISwitch *privateSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *freeSwitch;



@end

