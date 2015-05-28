//
//  EventDetailsViewController.h
//  turnip
//
//  Created by Per on 4/23/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FXBlurView.h"
#import <QuartzCore/QuartzCore.h>

@interface SAEEventDetailsViewController : UIViewController <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *event;
@property (nonatomic, strong) NSArray *data;

@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, strong) NSString *eventTitle;

@property (strong, nonatomic) IBOutlet UIImageView *profileImage;
@property (strong, nonatomic) IBOutlet UIImageView *requestHolderImage;
@property (strong, nonatomic) IBOutlet UIView *middleView;
@property (strong, nonatomic) IBOutlet UIView *bottomView;

@property (strong, nonatomic) IBOutlet UIButton *unattendButton;

@property (strong, nonatomic) IBOutlet UIButton *nextImageButton;
@property (strong, nonatomic) IBOutlet UIButton *messageButton;
@property (strong, nonatomic) IBOutlet UIButton *requestButton;
@property (strong, nonatomic) IBOutlet UIButton *attendButton;
@property (strong, nonatomic) IBOutlet UIButton *goingButton;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet FXBlurView *attendingView;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *imageLoader;

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *privateLabel;
@property (strong, nonatomic) IBOutlet UILabel *neighbourhoodLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *aboutLabel;
@property (strong, nonatomic) IBOutlet UILabel *goingLabel;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;

- (IBAction)profileImageTap:(UITapGestureRecognizer *)sender;
- (IBAction)messageButton:(id)sender;
- (IBAction)requestButton:(id)sender;
- (IBAction)nextImageButton:(id)sender;
- (IBAction)goingButton:(id)sender;
- (IBAction)attendButton:(id)sender;
- (IBAction)unattendButton:(id)sender;
- (IBAction)closeAttendingViewButton:(id)sender;


@end
