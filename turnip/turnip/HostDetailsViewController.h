//
//  HostDetailsViewController.h
//  turnip
//
//  Created by Per on 4/21/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HostDetailsViewController : UIViewController <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *event;
@property (nonatomic, strong) NSArray *data;

@property (strong, nonatomic) IBOutlet UIImageView *profileImage;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UITableView *tableView;


@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *privateLabel;
@property (strong, nonatomic) IBOutlet UILabel *neighbourhoodLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *aboutLabel;
@property (strong, nonatomic) IBOutlet UILabel *goingLabel;
@property (strong, nonatomic) IBOutlet UIButton *goingButton;

- (IBAction)deleteButton:(id)sender;
- (IBAction)editButton:(id)sender;
- (IBAction)teammateButton:(id)sender;
- (IBAction)scannerButton:(id)sender;
- (IBAction)nextImageButton:(id)sender;


@end
