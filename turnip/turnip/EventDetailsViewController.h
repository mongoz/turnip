//
//  EventDetailsViewController.h
//  turnip
//
//  Created by Per on 4/23/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import <UIKit/UIKit.h>


//, UITableViewDelegate, UITableViewDataSource
@interface EventDetailsViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, strong) NSArray *event;
@property (nonatomic, strong) NSArray *data;

@property (strong, nonatomic) IBOutlet UIImageView *profileImage;
@property (strong, nonatomic) IBOutlet UIImageView *requestHolderImage;

@property (strong, nonatomic) IBOutlet UIButton *nextImageButton;
@property (strong, nonatomic) IBOutlet UIButton *messageButton;
@property (strong, nonatomic) IBOutlet UIButton *requestButton;
@property (strong, nonatomic) IBOutlet UIButton *quitButton;
@property (strong, nonatomic) IBOutlet UIButton *goingButton;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *imageLoader;

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *privateLabel;
@property (strong, nonatomic) IBOutlet UILabel *neighbourhoodLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *capacityLabel;
@property (strong, nonatomic) IBOutlet UILabel *aboutLabel;
@property (strong, nonatomic) IBOutlet UILabel *goingLabel;

- (IBAction)quitParty:(id)sender;
- (IBAction)profileImageTap:(UITapGestureRecognizer *)sender;
- (IBAction)messageButton:(id)sender;
- (IBAction)requestButton:(id)sender;
- (IBAction)nextImageButton:(id)sender;
- (IBAction)goingButton:(id)sender;

@end
