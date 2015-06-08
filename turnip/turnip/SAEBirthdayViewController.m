//
//  SAEBirthdayViewController.m
//  turnip
//
//  Created by Per on 5/25/15.
//  Copyright (c) 2015 Stupidest App Ever. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SAEBirthdayViewController.h"
#import <Parse/Parse.h>
#import "DateTimePicker.h"
#import "ParseErrorHandlingController.h"

@interface SAEBirthdayViewController ()

@property (nonatomic, strong) DateTimePicker *datePicker;
@property (nonatomic, strong) NSString *selectedDate;

@end


@implementation SAEBirthdayViewController


- (void) viewDidLoad {
    
    [self.submitButton setEnabled:NO];
    self.submitButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.submitButton.layer.borderWidth = 1.0;
    self.submitButton.layer.cornerRadius = 5;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.datePicker = [[DateTimePicker alloc] initWithFrame:CGRectMake(0, screenHeight/2 + 60, screenWidth, screenHeight/2 + 60)];
        [self.datePicker addTargetForDoneButton:self action:@selector(donePressed)];
        [self.datePicker addTargetForCancelButton:self action:@selector(cancelPressed)];
        [self.view addSubview: self.datePicker];
        self.datePicker.hidden = YES;
        [self.datePicker setMode: UIDatePickerModeDate];
        [self.datePicker.picker addTarget:self action:@selector(pickerChanged:) forControlEvents:UIControlEventValueChanged];

        [self.datePicker maximumDate: [NSDate date]];
    });
}

-(void)donePressed {
    self.datePicker.hidden = YES;
}

-(void)cancelPressed {
    self.datePicker.hidden = YES;
    [self.selectBirthday setTitle:@"Select Birthday" forState:UIControlStateNormal];
    self.selectedDate = nil;
    
    
    [self.submitButton setEnabled:NO];
    self.submitButton.layer.borderColor = [UIColor blackColor].CGColor;
    [self.submitButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}

-(void)pickerChanged:(id)sender {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    // Set the date components you want
    NSString *dateComponents = @"MMMMd, yyyy";
    
    // The components will be reordered according to the locale
    NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:dateComponents options:0 locale:[NSLocale currentLocale]];
    
    [dateFormatter setDateFormat:dateFormat];

    NSString *dateString = [dateFormatter stringFromDate:[sender date]];
    
    [self.selectBirthday setTitle:dateString forState:UIControlStateNormal];
    
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    self.selectedDate = [dateFormatter stringFromDate:[sender date]];
    
    [self.submitButton setEnabled:YES];
     self.submitButton.layer.borderColor = [UIColor colorWithRed:0.549 green:0 blue:0.102 alpha:1].CGColor;
    [self.submitButton setTitleColor:[UIColor colorWithRed:0.592 green:0 blue:0 alpha:1] forState:UIControlStateNormal];
}


- (IBAction)submitButton:(id)sender {
    if (self.selectedDate != nil) {
        [PFUser currentUser][@"birthday"] = self.selectedDate;
        
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(error) {
                [ParseErrorHandlingController handleParseError:error];
            } else if(succeeded){
                if ([[PFUser currentUser][@"TOS"] isEqualToString:@"False"]) {
                    [self presentTosView];
                } else {
                    [self presentMapView];
                }
                
            }
        }];

    }
}


- (IBAction)selectBirthday:(id)sender {
    
    self.datePicker.hidden = NO;
    
}

- (void) presentMapView {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    UIViewController *mvc = [storyboard instantiateViewControllerWithIdentifier:@"tabBar"];
    [self presentViewController:mvc animated:YES completion:nil];
}

- (void) presentTosView {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    UIViewController *atvc = [storyboard instantiateViewControllerWithIdentifier:@"acceptTosView"];
    [self presentViewController:atvc animated:YES completion:nil];
}

@end
