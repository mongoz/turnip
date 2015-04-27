//
//  EventDetailsViewController.h
//  turnip
//
//  Created by Per on 4/23/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventDetailsViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, strong) NSArray *event;

@property (strong, nonatomic) IBOutlet UIImageView *profileImage;

@property (strong, nonatomic) IBOutlet UIButton *nextImageButton;
@property (strong, nonatomic) IBOutlet UIButton *messageButton;
@property (strong, nonatomic) IBOutlet UIButton *requestButton;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *imageLoader;

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *privateLabel;
@property (strong, nonatomic) IBOutlet UILabel *neighbourhoodLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *capacityLabel;
@property (strong, nonatomic) IBOutlet UILabel *aboutLabel;

- (IBAction)messageButton:(id)sender;
- (IBAction)requestButton:(id)sender;
- (IBAction)nextImageButton:(id)sender;
@end
