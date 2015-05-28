//
//  EditNextViewController.h
//  turnip
//
//  Created by Per on 3/10/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface EditNextViewController : UIViewController <UITextViewDelegate,
UITextFieldDelegate,
UIActionSheetDelegate,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate,
MBProgressHUDDelegate>

@property (strong, nonatomic) NSArray *currentEvent;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *location;
@property (strong, nonatomic) NSString *about;
@property (strong, nonatomic) NSNumber *cost;
@property (assign, nonatomic) BOOL isPrivate;
@property (assign, nonatomic) BOOL isFree;
@property (assign, nonatomic) BOOL isCreated;

@property (strong, nonatomic) IBOutlet UITextField *dateInputField;
@property (strong, nonatomic) IBOutlet UITextField *endTimeDate;


@property (strong, nonatomic) IBOutlet UIImageView *imageOne;
@property (strong, nonatomic) IBOutlet UIImageView *imageTwo;
@property (strong, nonatomic) IBOutlet UIImageView *imageThree;

@property (strong, nonatomic) MBProgressHUD * HUD;

- (IBAction)imageOneTapHandler:(UITapGestureRecognizer *)sender;
- (IBAction)imageTwoTapHandler:(UITapGestureRecognizer *)sender;
- (IBAction)imageThreeTapHandler:(UITapGestureRecognizer *)sender;

@property (strong, nonatomic) IBOutlet UIButton *backButton;

- (IBAction)backButtonHandler:(id)sender;
- (IBAction)saveButtonHandler:(id)sender;

@end
