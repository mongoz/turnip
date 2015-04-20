//
//  ProfileImageCollectionViewController.m
//  turnip
//
//  Created by Per on 4/5/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "ProfileImageCollectionViewController.h"
#import "Constants.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "profileAlbumCollectionViewCell.h"

@interface ProfileImageCollectionViewController ()

@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSIndexPath *indexPath;

@end

@implementation ProfileImageCollectionViewController

static NSString * const reuseIdentifier = @"FolderCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.photos = [[NSMutableArray alloc] init];
    
    [self.activitySpinner startAnimating];
    
    [self getPhotoAlbums];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) getPhotoAlbums {
    if ([FBSDKAccessToken currentAccessToken]) {
        
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/albums" parameters:nil] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            if (error) {
                NSLog(@"error %@", error);
            } else {
                NSArray *data = [result objectForKey:@"data"];
                for (NSDictionary *album in data) {
                    if ([[album valueForKey:@"name"] isEqualToString:@"Profile Pictures"]) {
                        [self downloadProfilePhots:[album valueForKey:@"id"]];
                    }
                }
            }
            
        }];
    } else {
        NSLog(@"access denied");
    }
}


- (void) downloadProfilePhots: (NSString *) albumId {
    NSString *path = [NSString stringWithFormat:@"/%@/photos", albumId];
    
    [[[FBSDKGraphRequest alloc] initWithGraphPath:path parameters:nil] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        NSArray *data = [result objectForKey:@"data"];
        
        for (NSDictionary *photos in data) {
            [self.photos addObject:photos];
        }
        [self.activitySpinner stopAnimating];
        self.activitySpinner.hidden = YES;
        [self.collectionView reloadData];
    }];

}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    profileAlbumCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    NSURL *url = [NSURL URLWithString:[[self.photos valueForKey:@"picture"] objectAtIndex:indexPath.row]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    cell.albumImage.image = [UIImage imageWithData:data];
    
    cell.backgroundColor = [UIColor blackColor];
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {   
    [[NSNotificationCenter defaultCenter] postNotificationName:@"profileImage" object:[[self.photos objectAtIndex:indexPath.row] valueForKey:@"picture"]];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)backNavigation:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
