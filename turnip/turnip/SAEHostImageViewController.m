//
//  SAEHostImageViewController.m
//  
//
//  Created by Per on 9/11/15.
//
//

#import "SAEHostSingleton.h"
#import "SAEHostImageViewController.h"
#import "SAEHostAccessoriesViewController.h"

@interface SAEHostImageViewController ()

@property (nonatomic, strong) SAEHostSingleton *event;
@property (nonatomic, strong) NSMutableArray *imageArray;
@property (nonatomic, strong) NSArray *colorArray;

@property (nonatomic, assign) NSInteger selectedRow;

@end

@implementation SAEHostImageViewController

@synthesize imageArray = _imageArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Host";
    
    self.event = [SAEHostSingleton sharedInstance];
    self.imageArray = [[NSMutableArray alloc] init];
    
    if (self.event.eventImage != nil) {
        [self.hostImage setImage: self.event.eventImage];
    }
    
    [self createPhotoArray];
    
    [self.hostImage setImage:[self.imageArray objectAtIndex:1]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Collection view data source

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.imageArray count];
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = (UICollectionViewCell *) [self.imageCollectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    
    UIImageView *imageView = (UIImageView *) [cell viewWithTag:100];
    
    [imageView setImage:[self.imageArray objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
    
    //Unselected the prevoius selected Cell
    UICollectionViewCell *aPreviousSelectedCell=  (UICollectionViewCell * )[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.selectedRow inSection:0]];
    aPreviousSelectedCell.layer.borderColor = [UIColor clearColor].CGColor;
    aPreviousSelectedCell.layer.borderWidth = 0.0f;
    
    //Selected the new one
    UICollectionViewCell *aSelectedCell = (UICollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    aSelectedCell.layer.borderColor = [UIColor lightGrayColor].CGColor;
    aSelectedCell.layer.borderWidth = 2.0f;
    
    self.selectedRow = indexPath.row;
    
    if (indexPath.row == 0) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle: nil
                                                                 delegate: self
                                                        cancelButtonTitle: @"Cancel"
                                                   destructiveButtonTitle: nil
                                                        otherButtonTitles: @"Photo library", @"Camera", nil];
        [actionSheet showInView:self.view];

    } else {
        self.event.eventImage = [self.imageArray objectAtIndex:indexPath.row];
        [self.hostImage setImage:[self.imageArray objectAtIndex:indexPath.row]];
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

#pragma mark - Utils


-(void) createPhotoArray {
    NSString *imageName = [NSString stringWithFormat:@"stock0.png"];
    UIImage *image = [UIImage imageNamed:imageName];
    [self.imageArray addObject:image];
    
    for (int i = 1; i <=11; i++) {
        NSString *imageName = [NSString stringWithFormat:@"stock%d.jpg", i];
        UIImage *image = [UIImage imageNamed:imageName];
        [self.imageArray addObject:image];
    }
    
}

#pragma mark - image handlers

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self choosePhotoFromExistingImages];
            break;
        case 1:
            [self takeNewPhotoFromCamera];
            break;
        default:
            break;
    }
}
- (void)takeNewPhotoFromCamera
{
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.sourceType = UIImagePickerControllerSourceTypeCamera;
        controller.allowsEditing = YES;
        controller.delegate = self;
        [self.tabBarController presentViewController: controller animated: YES completion: nil];
    } else {
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
    }
}
-(void)choosePhotoFromExistingImages
{
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        controller.allowsEditing = YES;
        controller.delegate = self;
        
        [self.tabBarController presentViewController: controller animated: YES completion: nil];
        
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    
    [self.hostImage setImage:chosenImage];
    self.event.eventImage = chosenImage;
    
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}



 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     if ([segue.identifier isEqualToString:@"hostImageFinalSegue"]) {
         
         SAEHostAccessoriesViewController *destViewController = (SAEHostAccessoriesViewController *) segue.destinationViewController;
         
         destViewController.hostImage = [self.hostImage image];
     }
 }
 

- (IBAction)backButtonHandler:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)nextButtonHandler:(id)sender {
    [self performSegueWithIdentifier:@"hostImageFinalSegue" sender:nil];
}
@end
