//
//  SAEHostImageViewController.m
//  
//
//  Created by Per on 9/11/15.
//
//

#import "SAEHostImageViewController.h"

@interface SAEHostImageViewController ()

@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic, strong) NSArray *colorArray;
@property (nonatomic, assign) BOOL drawImages;

@end

@implementation SAEHostImageViewController

@synthesize imageArray = _imageArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Host";
    
    self.drawImages = YES;
    self.imageArray = [[NSArray alloc] init];
    self.colorArray = [[NSArray alloc] initWithArray:[self createColorArray]];
    
    NSLog(@"color: %@", self.colorArray);
    
    NSMutableArray *collector = [[NSMutableArray alloc] initWithCapacity:0];
    ALAssetsLibrary *assetsLibrary = [SAEHostImageViewController defaultAssetsLibrary];
    
    if([ALAssetsLibrary authorizationStatus]) {
        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                //Enumerate through the group to get access to the photos.
                [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                     if (asset) {
                         [collector addObject:asset];
                     }
                 }];
                [self setPhotos: collector];
                //[self.imageCollectionView reloadData];
            
        } failureBlock:^(NSError *error) {
            NSLog(@"Error Description %@",[error description]);
        }];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Permission Denied"
                                                        message:@"Please allow the application to access your photo and videos in settings panel of your device"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles: nil];
        [alertView show];
    
    }
}

-(void)setPhotos:(NSArray *)photos {
    if (_imageArray != photos) {
        _imageArray = photos;
        [self.imageCollectionView reloadData];
    }
}

- (NSMutableArray *) createColorArray {
    NSMutableArray *colors = [NSMutableArray array];
    
    float INCREMENT = 0.05;
    for (float hue = 0.0; hue < 1.0; hue += INCREMENT) {
        UIColor *color = [UIColor colorWithHue:hue
                                    saturation:1.0
                                    brightness:1.0
                                         alpha:1.0];
        [colors addObject:color];
    }
    
    return colors;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Collection view data source

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.imageArray count] + 1;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = (UICollectionViewCell *) [self.imageCollectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    
    UIImageView *imageView = (UIImageView *) [cell viewWithTag:100];
    
    if (self.drawImages) {
        cell.backgroundColor = [UIColor blackColor];
        if (indexPath.row == 0) {
            [imageView setImage:[UIImage imageNamed:@"logo.png"]];
        } else {
            ALAsset *asset = [self.imageArray objectAtIndex:indexPath.row - 1];
            [imageView setImage:[UIImage imageWithCGImage:[asset thumbnail]]];
        }
    } else {
        [imageView setImage:nil];
        if (indexPath.row == 0) {
            cell.backgroundColor = [UIColor blueColor];
        } else {
            cell.backgroundColor = [UIColor greenColor];
        }
    }
    
    return cell;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.drawImages) {
        if (indexPath.row == 0) {
            self.drawImages = NO;
            [self.imageCollectionView reloadData];
        } else {
            ALAsset *asset = [self.imageArray objectAtIndex:indexPath.row - 1];
            ALAssetRepresentation *defaultRep = [asset defaultRepresentation];
            UIImage *image = [UIImage imageWithCGImage:[defaultRep fullScreenImage] scale:[defaultRep scale] orientation:UIImageOrientationUp];
            [self.hostImage setImage:image];
        }
    } else {
        if (indexPath.row == 0) {
            self.drawImages = YES;
            [self.imageCollectionView reloadData];
        } else {
            NSLog(@"indexPath: %ld", (long)indexPath.row);
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

+ (ALAssetsLibrary *)defaultAssetsLibrary {
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)backButtonHandler:(id)sender {
}

- (IBAction)nextButtonHandler:(id)sender {
}
@end
