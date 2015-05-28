//
//  SAEBirthdayViewController.h
//  turnip
//
//  Created by Per on 5/25/15.
//  Copyright (c) 2015 Stupidest App Ever. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SAEBirthdayViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *submitButton;
@property (strong, nonatomic) IBOutlet UIButton *selectBirthday;


- (IBAction)submitButton:(id)sender;
- (IBAction)selectBirthday:(id)sender;

@end
