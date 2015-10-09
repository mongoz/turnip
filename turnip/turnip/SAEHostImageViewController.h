//
//  SAEHostImageViewController.h
//  
//
//  Created by Per on 9/11/15.
//
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface SAEHostImageViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIActionSheetDelegate,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *hostImage;
@property (strong, nonatomic) IBOutlet UICollectionView *imageCollectionView;

- (IBAction)backButtonHandler:(id)sender;
- (IBAction)nextButtonHandler:(id)sender;
@end
