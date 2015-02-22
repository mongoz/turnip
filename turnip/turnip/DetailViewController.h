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
#import "TurnipEvent.h"


@interface DetailViewController : UIViewController

@property (nonatomic, strong) TurnipEvent *event;
@property (nonatomic, strong) TurnipEvent *data;

@property (nonatomic, strong) NSArray *yourEvent;

@property (nonatomic, assign) BOOL host;
@property (nonatomic, assign) BOOL deleted;

@property (nonatomic, copy) NSString *objectId;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *openLabel;
@property (strong, nonatomic) IBOutlet UILabel *freePaidLabel;
@property (strong, nonatomic) IBOutlet UILabel *aboutLabel;

@property (strong, nonatomic) IBOutlet PFImageView *imageView1;
@property (strong, nonatomic) IBOutlet PFImageView *imageView2;
@property (strong, nonatomic) IBOutlet PFImageView *imageView3;
@property (strong, nonatomic) IBOutlet PFImageView *profileImage;

@property (strong, nonatomic) IBOutlet UIButton *requestButton;
@property (strong, nonatomic) IBOutlet UIButton *sidemenuButton;

@property (strong, nonatomic) IBOutlet UIView *headerView;

- (IBAction)sidemenuButtonHandler:(id)sender;
- (IBAction)requestButtonHandler:(id)sender;
- (IBAction)profileImageTapHandler:(UITapGestureRecognizer *)sender;
@end
