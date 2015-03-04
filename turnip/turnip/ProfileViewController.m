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
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "SWRevealViewController.h"

@interface ProfileViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSArray *thrown;
@property (nonatomic, strong) NSArray *attended;
@property (nonatomic, assign) NSInteger nbItems;
@property (nonatomic, assign) BOOL thrownPressed;
@property (nonatomic, assign) BOOL editProfile;

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
    
    self.editProfile = NO;
    self.thrownPressed = YES;
    self.sideMenuButton.hidden = YES;
    self.headerTitleLabel.hidden = YES;
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    if ([user.objectId isEqual:[PFUser currentUser].objectId]) {
        [self loadFacebookData];

    }
    else if (user == nil) {
        [self loadFacebookData];
        self.sideMenuButton.hidden = NO;
        self.headerTitleLabel.hidden = NO;
    }
    else {
        [self drawFacebookData];
    }
    [self queryForThrownParties];
    [self queryForPartiesAttended];
}

- (void) loadFacebookData {
    FBRequest *request = [FBRequest requestForMe];
    
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result is a dictionary with the user's Facebook data
            NSDictionary *userData = (NSDictionary *)result;
            
            NSString *facebookID = userData[@"id"];
            NSString *name = userData[@"name"];
            NSString *birthday = userData[@"birthday"];
            
            self.headerTitleLabel.text = name;
            self.ageLabel.text = @([self calculateAge:birthday]).stringValue;
            self.bioLabel.text = [[PFUser currentUser] valueForKey:@"bio"];
            
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
    }];
}

- (void) drawFacebookData {
    
    NSString *facebookID = [user objectForKey:@"facebookId"];
    
    NSArray *name = [[user objectForKey:@"name"] componentsSeparatedByString: @" "];
    
    self.bioLabel.text = [user objectForKey:@"bio"];
    
    self.ageLabel.text = @([self calculateAge:[user objectForKey:@"birthday"]]).stringValue;
    self.navigationItem.title = [name objectAtIndex:0];
    
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

- (int) calculateAge: (NSString *) birthday {

    NSDate *todayDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    int time = [todayDate timeIntervalSinceDate:[dateFormatter dateFromString:birthday]];
    int allDays = (((time/60)/60)/24);
    int days = allDays%365;
    int years = (allDays-days)/365;
    
    return  years;
}

#pragma mark - parse queries

- (void) queryForThrownParties {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Finished"];
    
    if (self.user == nil) {
         [query whereKey:@"user" equalTo:[PFUser currentUser]];
    } else {
         [query whereKey:@"user" equalTo:self.user];
    }
   
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error) {
            NSLog(@"Error in geo query!: %@", error);
        } else {
            if([objects count] == 0) {
            } else {
                self.thrown = [[NSArray alloc] initWithArray:objects];
                self.nbItems = [self.thrown count];
                [self.collectionView reloadData];
            }
        }
    }];
}

- (void) queryForPartiesAttended {
    PFQuery *query = [PFQuery queryWithClassName:@"Finished"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error) {
            NSLog(@"Error in geo query!: %@", error);
        } else {
            if([objects count] == 0) {
            } else {
                for(PFObject *event in objects) {
                    PFRelation *relation = [event relationForKey:@"attended"];
                    PFQuery *query = [relation query];
                    
                    if (self.user == nil) {
                        [query whereKey:@"objectId" equalTo:[PFUser currentUser].objectId];
                    } else {
                        [query whereKey:@"objectId" equalTo:self.user.objectId];
                    }
                    
                    [query findObjectsInBackgroundWithBlock:^(NSArray *object, NSError *error) {
                        if ([object count] != 0) {
                            self.attended = [[NSArray alloc] initWithObjects:event, nil];
                            //self.nbItems = [self.attended count];
                        }
                    }];
                }
            }
        }
    }];
}

- (void) saveProfileToParse {
    [PFUser currentUser][@"bio"] = self.bioTextView.text;
    
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
    
    cell.backgroundColor = [UIColor whiteColor];
    
    UIImageView *partyImageView = (UIImageView *) [cell viewWithTag:100];
    
    if (self.thrownPressed) {
        PFFile *file = [[self.thrown valueForKey:@"image1"] objectAtIndex:indexPath.row];
        
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:data];
                partyImageView.image = image;
            } else
                NSLog(@"error: %@", error);
        }];
    } else {
        PFFile *file = [[self.attended valueForKey:@"image1"] objectAtIndex:indexPath.row];
        
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:data];
                partyImageView.image = image;
            }
        }];
    }
    
    
    
    return cell;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 1;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 1;
}

#pragma mark -
#pragma mark Notification center

- (void) editUserNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:TurnipEditUserProfileNotification]){
        self.editProfile = YES;
        self.bioTextView.text = self.bioLabel.text;
        self.bioTextView.hidden = NO;
        self.bioLabel.hidden = YES;
        self.finishEditingProfile.hidden = NO;
        self.sideMenuButton.hidden = YES;
    }
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

#pragma mark -
#pragma mark button handlers
- (IBAction)sideMenuButtonHandler:(id)sender {
    SWRevealViewController *revealViewController = self.revealViewController;
    [revealViewController rightRevealToggleAnimated:YES];
}

- (IBAction)partiesThrowButtonHandler:(id)sender {
    [self.partiesThrownButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.partiesAttendedButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    self.thrownPressed = YES;
    self.nbItems = [self.thrown count];
    [self.collectionView reloadData];
    
}

- (IBAction)partiesAttendedButtonHandler:(id)sender {
    [self.partiesThrownButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.partiesAttendedButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    self.thrownPressed = NO;
    self.nbItems = [self.attended count];
    [self.collectionView reloadData];
}

- (IBAction)finishEditingProfileHandler:(id)sender {
    [self saveProfileToParse];
    self.bioTextView.hidden = YES;
    self.bioLabel.text = self.bioTextView.text;
    self.bioLabel.hidden = NO;
    self.finishEditingProfile.hidden = YES;
    self.sideMenuButton.hidden = NO;
}

@end
