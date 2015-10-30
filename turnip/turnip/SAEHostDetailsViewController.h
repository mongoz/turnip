//
//  SAEHostDetailsViewController.h
//  turnip
//
//  Created by Per on 10/10/15.
//  Copyright (c) 2015 Stupidest App Ever. All rights reserved.
//

#import "SAEEvent.h"
#import <UIKit/UIKit.h>

@interface SAEHostDetailsViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) IBOutlet UIButton *attendingButton;

- (IBAction)backNavigation:(id)sender;

- (IBAction)scannerButton:(id)sender;
- (IBAction)teammateButton:(id)sender;
- (IBAction)editButton:(id)sender;
- (IBAction)requestButton:(id)sender;

- (IBAction)attendingButton:(id)sender;
@end
