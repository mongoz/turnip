//
//  ScannerViewController.h
//  turnip
//
//  Created by Per on 2/13/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailViewController.h"

@import AVFoundation;

@interface ScannerViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) NSString *eventId;

- (IBAction)backNavigationButton:(id)sender;
@end
