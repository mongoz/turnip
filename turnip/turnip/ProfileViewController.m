//
//  ProfileViewController.m
//  turnip
//
//  Created by Per on 1/19/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "ProfileViewController.h"
#import "Constants.h"
#import <Parse/Parse.h>
#import "ParseErrorHandlingController.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "SWRevealViewController.h"
#import "SAEMessagingViewController.h"
#import "ProfileImageCollectionViewController.h"
#import "SAEUtilityFunctions.h"
#import "SAERatingViewController.h"

@interface ProfileViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSArray *thrown;
@property (nonatomic, strong) NSMutableArray *attended;
@property (nonatomic, assign) NSInteger nbItems;
@property (nonatomic, assign) BOOL thrownPressed;
@property (nonatomic, assign) BOOL editProfile;
@property (nonatomic, assign) BOOL messageActive;
@property (nonatomic, strong) NSString *profileUrl;

@end

@implementation ProfileViewController
@synthesize user;

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(editUserNotification:)
                                                 name: TurnipEditUserProfileNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editProfileImageNotification:) name:@"profileImage" object:nil];
    
    self.editProfile = NO;
    self.thrownPressed = NO;
    self.messageActive = NO;
    self.attended = [[NSMutableArray alloc] init];
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    if ([[user valueForKey:@"objectId"] isEqual:[PFUser currentUser].objectId]) {
        [self loadFacebookData];
        self.sideMenuButton.hidden = YES;
        self.backNavigationButton.hidden = NO;
    }
    else if (user == nil) {
        [self loadFacebookData];
        self.backNavigationButton.hidden = YES;
    }
    else {
        self.backNavigationButton.hidden = NO;
        self.messageActive = YES;
        [self drawFacebookData];
    }
    [self queryForThrownParties];
    [self queryForPartiesAttended];
}

- (void) loadFacebookData {
    if ([FBSDKAccessToken currentAccessToken]) {
        
        [[PFUser currentUser] fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if(!error) {
                NSNumber *rating = [[PFUser currentUser] valueForKey:@"rating"];
                
                if ([rating isEqual:[NSNull null]]) {
                    self.ratingLabel.text = [NSString stringWithFormat:@"Rating: 0"];
                } else {
                    self.ratingLabel.text = [NSString stringWithFormat:@"Rating: %@", [rating stringValue]];
                }
                
                self.bioLabel.numberOfLines = 0;
                self.bioLabel.text = [[PFUser currentUser] valueForKey:@"bio"];
                [self.bioLabel sizeToFit];
            } else {
                [ParseErrorHandlingController handleParseError:error];
            }
        }];
        
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                // result is a dictionary with the user's Facebook data
                NSDictionary *userData = (NSDictionary *)result;
                
                NSString *facebookID = userData[@"id"];
                NSArray *name = [userData[@"name"] componentsSeparatedByString:@" "];
                NSString *birthday = [[PFUser currentUser] valueForKey:@"birthday"];
                
                NSString *navigationTitle = [NSString stringWithFormat:@"%@, %@", [name objectAtIndex:0], @([SAEUtilityFunctions calculateAge:birthday]).stringValue];
                
                self.navigationItem.title = navigationTitle;
                
                // Should change this to background thread
                if ([[PFUser currentUser] valueForKey:@"profileImage"] != nil) {
                    NSURL *url = [NSURL URLWithString: [[PFUser currentUser] valueForKey:@"profileImage"]];
                    NSData *data = [NSData dataWithContentsOfURL:url];
                    self.profileImage.image = [UIImage imageWithData:data];
                } else {
                    // URL should point to https://graph.facebook.com/{facebookId}/picture?type=large&return_ssl_resources=1
                    NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
                    
                    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:pictureURL];
                    
                    // Run network request asynchronously
                    [NSURLConnection sendAsynchronousRequest:urlRequest
                                                       queue:[NSOperationQueue mainQueue]
                                           completionHandler:
                     ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                         if (connectionError == nil && data != nil) {
                             // Set the image in the header imageView
                             self.profileImage.image = [UIImage imageWithData:data];
                         }
                     }];
                }
            }
            
        }];
    }
    
}

- (void) drawFacebookData {
    
    [self.sideMenuButton setImage:[UIImage imageNamed:@"envelope"] forState:UIControlStateNormal];
    
    NSString *facebookID = [user valueForKey:@"facebookId"];
    
    NSArray *name = [[user valueForKey:@"name"] componentsSeparatedByString: @" "];
    
    NSString *navigationTitle = [NSString stringWithFormat:@"%@, %@", [name objectAtIndex:0], @([SAEUtilityFunctions calculateAge:[user valueForKey:@"birthday"]]).stringValue];
    
    self.bioLabel.numberOfLines = 0;
    self.bioLabel.text = [user valueForKey:@"bio"];
    [self.bioLabel sizeToFit];
    
    NSNumber *rating = [[PFUser currentUser] valueForKey:@"rating"];
    
    if ([rating isEqual:[NSNull null]]) {
        self.ratingLabel.text = [NSString stringWithFormat:@"Rating: 0"];
    } else {
        self.ratingLabel.text = [NSString stringWithFormat:@"Rating: %@",[rating stringValue]];
    }
    
    self.navigationItem.title = navigationTitle;
    
    if ([user valueForKey:@"profileImage"] != nil) {
        NSURL *url = [NSURL URLWithString: [user valueForKey:@"profileImage"]];
        NSData *data = [NSData dataWithContentsOfURL:url];
        self.profileImage.image = [UIImage imageWithData:data];
    } else {
        // URL should point to https://graph.facebook.com/{facebookId}/picture?type=large&return_ssl_resources=1
        NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
        
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:pictureURL];
        
        // Run network request asynchronously
        [NSURLConnection sendAsynchronousRequest:urlRequest
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:
         ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
             if (connectionError == nil && data != nil) {
                 // Set the image in the header imageView
                 self.profileImage.image = [UIImage imageWithData:data];
             }
         }];
    }
}

#pragma mark - parse queries

- (void) queryForThrownParties {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Finished"];
    
    if (self.user == nil) {
         [query whereKey:@"user" equalTo:[PFUser currentUser]];
    } else {
         [query whereKey:@"user" equalTo:self.user];
    }
    [query orderByDescending:@"updatedAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error) {
            [ParseErrorHandlingController handleParseError:error];
        } else {
            if([objects count] == 0) {
            } else {
                self.thrown = [[NSArray alloc] initWithArray:objects];
                self.nbItems = [self.thrown count];
            }
        }
    }];
}

- (void) queryForPartiesAttended {
    PFQuery *query = [PFQuery queryWithClassName:@"Finished"];
    
    [self.collectionViewActivitySpinner startAnimating];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error) {
            [ParseErrorHandlingController handleParseError:error];
        } else {
            if([objects count] == 0) {
            } else {
                for(PFObject *event in objects) {
                    PFRelation *relation = [event relationForKey:@"attended"];
                    PFQuery *query = [relation query];
                    
                    if (self.user == nil) {
                        [query whereKey:@"objectId" equalTo:[PFUser currentUser].objectId];
                    } else {
                        [query whereKey:@"objectId" equalTo:[self.user valueForKey:TurnipParsePostIdKey]];
                    }
                    [query orderByDescending:@"updatedAt"];
                    [query findObjectsInBackgroundWithBlock:^(NSArray *object, NSError *error) {
                        [self.collectionViewActivitySpinner stopAnimating];
                        self.collectionViewActivitySpinner.hidden = YES;
                        if ([object count] != 0) {
                            [self.attended addObject:event];
                            self.nbItems = [self.attended count];

                            [self.collectionView reloadData];
                        }
                    }];
                }
            }
        }
    }];
}

- (void) saveProfileToParse {
    [PFUser currentUser][@"bio"] = self.bioTextView.text;
    
    if (self.profileUrl != nil) {
        [PFUser currentUser][@"profileImage"] = self.profileUrl;
    }
    
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"saved");
        }
        else {
            NSLog(@"error: %@", error);
        }
    }];
}

#pragma mark - Collection view data source

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.nbItems;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = (UICollectionViewCell *) [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor blackColor];
    
    UIImageView *partyImageView = (UIImageView *) [cell viewWithTag:100];
    
    UILabel *partyImageLabel = (UILabel *) [cell viewWithTag:101];
    
    if (self.thrownPressed) {
        PFFile *file = [[self.thrown valueForKey:@"image1"] objectAtIndex:indexPath.row];
        partyImageLabel.text = [[self.thrown valueForKey:@"title"] objectAtIndex:indexPath.row];
        
        
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:data];
                partyImageView.image = image;
            } else
                NSLog(@"error: %@", error);
        }];
    } else {
        PFFile *file = [[self.attended valueForKey:@"image1"] objectAtIndex:indexPath.row];
        partyImageLabel.text = [[self.attended valueForKey:@"title"] objectAtIndex:indexPath.row];
        
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:data];
                partyImageView.image = image;
            }
        }];
    }
    
    
    
    return cell;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!self.editProfile) {
        if (self.thrownPressed) {
            [self performSegueWithIdentifier:@"ratingViewSegue" sender:indexPath];
        } else  {
            [self performSegueWithIdentifier:@"ratingViewSegue" sender:indexPath];
        }
        
    }
   
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 1;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 1;
}

//- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    
//    return 160;
//}

- (void) editEventImage {
    for (UICollectionViewCell *cell in self.collectionView.visibleCells) {
        UIImageView *image = (UIImageView *) [cell viewWithTag:102];
        if ([image isHidden]) {
            image.hidden = NO;
        } else {
            image.hidden = YES;
        }
    }
}

#pragma mark -
#pragma mark Notification center

- (void) editUserNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:TurnipEditUserProfileNotification]){
        self.editProfile = YES;
        self.profileXImage.hidden = NO;
        self.bioTextView.text = self.bioLabel.text;
        self.bioTextView.hidden = NO;
        self.bioLabel.hidden = YES;
    //    [self editEventImage];
        [self.sideMenuButton setImage:[UIImage imageNamed:@"editprofile"] forState:UIControlStateNormal];
    }
}

- (void) editProfileImageNotification:(NSNotification *) note {
    
    self.profileUrl = [note object];
    
    NSURL *url = [NSURL URLWithString: [note object]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    self.profileImage.image = [UIImage imageWithData:data];
}

#pragma mark - textfield handlers

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    self.bioTextView.text = @"";
    self.bioTextView.textColor = [UIColor blackColor];
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{
    
    if(self.bioTextView.text.length == 0){
        self.bioTextView.text = self.bioLabel.text;
        [self.bioTextView resignFirstResponder];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.bioTextView resignFirstResponder];
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)string {
    // Prevent crashing undo bug – see note below.
    if(range.length + range.location > textView.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [textView.text length] + [string length] - range.length;
    return (newLength > 70) ? NO : YES;
}

#pragma mark -
#pragma mark button handlers
- (IBAction)sideMenuButtonHandler:(id)sender {
    if (self.editProfile) {
        [self.bioTextView resignFirstResponder];
        [self saveProfileToParse];
        self.profileXImage.hidden = YES;
        self.bioTextView.hidden = YES;
        self.bioLabel.text = self.bioTextView.text;
        self.bioLabel.hidden = NO;
       // [self editEventImage];
        [self.sideMenuButton setImage:[UIImage imageNamed:@"gearWhite"] forState:UIControlStateNormal];
        self.editProfile = NO;
    } else if (self.messageActive) {
        [self performSegueWithIdentifier:@"messageSegue" sender:nil];
    }
    else {
        SWRevealViewController *revealViewController = self.revealViewController;
        [revealViewController rightRevealToggleAnimated:YES];
    }

}

- (IBAction)partiesThrowButtonHandler:(id)sender {
    [self.partiesThrownButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.partiesAttendedButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    
    self.thrownPressed = YES;
    self.nbItems = [self.thrown count];
    [self.collectionView reloadData];
    
}

- (IBAction)partiesAttendedButtonHandler:(id)sender {
    [self.partiesThrownButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.partiesAttendedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.thrownPressed = NO;
    self.nbItems = [self.attended count];
    [self.collectionView reloadData];
}

- (IBAction)backNavigationButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - navigation

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"messageSegue"]) {
        SAEMessagingViewController *destViewController = segue.destinationViewController;
        destViewController.user = user;
    }
    
    if([segue.identifier isEqualToString:@"ratingViewSegue"]) {
        NSIndexPath *path = sender;
        SAERatingViewController *destViewController = segue.destinationViewController;
        if (self.thrownPressed) {
            destViewController.name = [[self.thrown valueForKey:@"title"] objectAtIndex: path.row];
            destViewController.objectId = [[self.thrown valueForKey:@"objectId"] objectAtIndex:path.row];
        } else {
            destViewController.name = [[self.attended valueForKey:@"title"] objectAtIndex: path.row];
            destViewController.objectId = [[self.attended valueForKey:@"objectId"] objectAtIndex:path.row];
        }
    }
}

- (IBAction)profileImageTap:(UITapGestureRecognizer *)sender {
    
    if (self.editProfile) {
        [self performSegueWithIdentifier:@"profileImageSegue" sender:nil];
    }
    
}

- (IBAction)eventCellXTap:(UITapGestureRecognizer *)sender {
    
    NSLog(@"view: %@", sender.view.superview.superview);
    
}
@end
