//
//  ProfileViewController.h
//  turnip
//
//  Created by Per on 1/19/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ProfileViewController : UIViewController <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *collectionViewActivitySpinner;

@property (strong, nonatomic) IBOutlet UIImageView *profileImage;
@property (strong, nonatomic) IBOutlet UIImageView *profileXImage;

@property (strong, nonatomic) NSArray *user;

@property (strong, nonatomic) IBOutlet UITextView *bioTextView;
@property (strong, nonatomic) IBOutlet UILabel *bioLabel;
@property (strong, nonatomic) IBOutlet UILabel *ratingLabel;

@property (strong, nonatomic) IBOutlet UIButton *sideMenuButton;
@property (strong, nonatomic) IBOutlet UIButton *partiesThrownButton;
@property (strong, nonatomic) IBOutlet UIButton *partiesAttendedButton;
@property (strong, nonatomic) IBOutlet UIButton *backNavigationButton;

- (IBAction)sideMenuButtonHandler:(id)sender;
- (IBAction)partiesThrowButtonHandler:(id)sender;
- (IBAction)partiesAttendedButtonHandler:(id)sender;
- (IBAction)backNavigationButton:(id)sender;

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *profileImageTap;
- (IBAction)profileImageTap:(UITapGestureRecognizer *)sender;

- (IBAction)eventCellXTap:(UITapGestureRecognizer *)sender;
@end