//
//  DetailViewController.h
//  turnip
//
//  Created by Per on 1/14/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface DetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

//@property (nonatomic, strong) TurnipEvent *event;
@property (nonatomic, strong) NSArray *event;

@property (nonatomic, strong) NSArray *yourEvent;
@property (nonatomic, strong) NSArray *data;

@property (nonatomic, assign) BOOL host;
@property (nonatomic, assign) BOOL deleted;

@property (nonatomic, copy) NSString *objectId;

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *openLabel;
@property (strong, nonatomic) IBOutlet UILabel *freePaidLabel;
@property (strong, nonatomic) IBOutlet UILabel *aboutLabel;
@property (strong, nonatomic) IBOutlet UILabel *neighbourhoodLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;

@property (strong, nonatomic) IBOutlet PFImageView *imageView1;
@property (strong, nonatomic) IBOutlet PFImageView *imageView2;
@property (strong, nonatomic) IBOutlet PFImageView *imageView3;
@property (strong, nonatomic) IBOutlet PFImageView *profileImage;
@property (strong, nonatomic) IBOutlet UIButton *sideMenuButton;
@property (strong, nonatomic) IBOutlet UIButton *requestButton;
@property (strong, nonatomic) IBOutlet UIButton *attendButton;
@property (strong, nonatomic) IBOutlet UIButton *messageButton;

@property (strong, nonatomic) IBOutlet UIButton *backNavigationButton;

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *fullScreenImageView;
@property (strong, nonatomic) IBOutlet UIImageView *fullScreenImage;

- (IBAction)attendButton:(id)sender;
- (IBAction)requestButtonHandler:(id)sender;
- (IBAction)profileImageTapHandler:(UITapGestureRecognizer *)sender;
- (IBAction)image1TapHandler:(UITapGestureRecognizer *)sender;
- (IBAction)image2TapHandler:(UITapGestureRecognizer *)sender;
- (IBAction)image3TapHandler:(UITapGestureRecognizer *)sender;
- (IBAction)fullScreenImageHandler:(UITapGestureRecognizer *)sender;
- (IBAction)messageButton:(id)sender;

- (IBAction)backNavigationButton:(id)sender;
- (IBAction)sideMenuButton:(id)sender;




@end
