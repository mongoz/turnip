//
//  EditViewController.h
//  turnip
//
//  Created by Per on 3/9/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditViewController : UIViewController <UITextViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSArray *currentEvent;

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
