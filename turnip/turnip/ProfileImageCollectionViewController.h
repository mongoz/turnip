//
//  ProfileImageCollectionViewController.h
//  turnip
//
//  Created by Per on 4/5/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileImageCollectionViewController : UICollectionViewController

- (IBAction)backNavigation:(id)sender;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activitySpinner;
@end
