//
//  SecondViewController.m
//  partay
//
//  Created by Per on 1/4/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "ThrowViewController.h"
#import "DateTimePicker.h"
#import <Parse/Parse.h>
#import "Constants.h"

@interface ThrowViewController ()

@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) DateTimePicker *datePicker;
@property (nonatomic, strong) DateTimePicker *endTimePicker;
@property (nonatomic, assign) BOOL privateChecked;
@property (nonatomic, assign) BOOL publicChecked;
@property (nonatomic, assign) BOOL paidChecked;

@property (nonatomic, strong) UIImageView *lastImagePressed;
@property (nonatomic, strong) NSMutableArray *images;

@end

@implementation ThrowViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.images = [[NSMutableArray alloc] init];
    
    UIView *dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    
    self.imageOne.userInteractionEnabled = YES;
    self.imageTwo.userInteractionEnabled = YES;
    self.imageThree.userInteractionEnabled = YES;
    
    self.selectedDate = [NSDate new];
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.day = 30;
    NSCalendar *theCalendar = [NSCalendar currentCalendar];
    NSDate *maxDate = [theCalendar dateByAddingComponents:dayComponent toDate:[NSDate date] options:0];
    
    self.aboutField.text = @"About";
    self.aboutField.textColor = [UIColor blackColor];
    self.aboutField.delegate = self;
    
    self.privateChecked = NO;
    self.paidChecked = NO;
    self.publicChecked = NO;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    self.datePicker = [[DateTimePicker alloc] initWithFrame:CGRectMake(0, screenHeight/2 + 60, screenWidth, screenHeight/2 + 60)];
    [self.datePicker addTargetForDoneButton:self action:@selector(donePressed)];
    [self.datePicker addTargetForCancelButton:self action:@selector(cancelPressed)];
    [self.view addSubview: self.datePicker];
    self.datePicker.hidden = YES;
    [self.datePicker setMode: UIDatePickerModeDateAndTime];
    [self.datePicker.picker addTarget:self action:@selector(pickerChanged:) forControlEvents:UIControlEventValueChanged];
    [self.datePicker minimumDate: self.selectedDate];
    [self.datePicker maximumDate: maxDate];
    
    self.dateInputField.delegate = self;
    self.dateInputField.inputView = dummyView;
    
    self.endTimePicker = [[DateTimePicker alloc] initWithFrame:CGRectMake(0, screenHeight/2 + 60, screenWidth, screenHeight/2 + 60)];
    [self.endTimePicker addTargetForDoneButton:self action:@selector(timeDonePressed)];
    [self.endTimePicker addTargetForCancelButton:self action:@selector(timeCancelPressed)];
    [self.view addSubview: self.endTimePicker];
    self.endTimePicker.hidden = YES;
    [self.endTimePicker setMode: UIDatePickerModeTime];
    [self.endTimePicker.picker addTarget:self action:@selector(timePickerChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.endTimeDate.delegate = self;
    self.endTimeDate.inputView = dummyView;
}

-(void)pickerChanged:(id)sender {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd hh:mm a";
    self.selectedDate = [sender date];

    self.dateInputField.text = [dateFormatter stringFromDate: self.selectedDate];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.dateInputField) {
        self.datePicker.hidden = NO;
    }
    else if (textField == self.endTimeDate) {
        self.endTimePicker.hidden = NO;
    }
    
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
   
    if (textField == self.dateInputField) {
        self.datePicker.hidden = YES;
        [self.dateInputField resignFirstResponder];
    }
    else if (textField == self.endTimeDate) {
        self.endTimePicker.hidden = YES;
        [self.endTimePicker resignFirstResponder];
    }
    
}

#pragma mark - Date/Time picker delegates

- (void) timePickerChanged: (id) sender {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"hh:mm a";
    self.endTimeDate.text = [dateFormatter stringFromDate: [sender date]];
}

- (void) timeDonePressed {
    self.endTimePicker.hidden = YES;
    [self.endTimePicker resignFirstResponder];
}

- (void) timeCancelPressed {
    self.endTimePicker.hidden = YES;
    self.endTimeDate.text = @"";
    [self.endTimeDate resignFirstResponder];
}

-(void)donePressed {
    self.datePicker.hidden = YES;
    [self.dateInputField resignFirstResponder];
}

-(void)cancelPressed {
    self.datePicker.hidden = YES;
    self.dateInputField.text = @"";
    [self.dateInputField resignFirstResponder];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [self.tabBarController.tabBar setHidden:YES];
}

- (void) viewWillDisappear:(BOOL)animated {
    [self.tabBarController.tabBar setHidden:NO];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.titleField resignFirstResponder];
    [self.aboutField resignFirstResponder];
    [self.dateInputField resignFirstResponder];
    [self.endTimeDate resignFirstResponder];
    
    self.endTimePicker.hidden = YES;
    self.datePicker.hidden = YES;
}

# pragma mark - button controll handlers

- (IBAction) backButtonHandler:(id)sender {
    self.tabBarController.selectedIndex = 0;
}

- (IBAction) createButtonHandler:(id)sender {
    [self.titleField resignFirstResponder];
    
    self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview: self.HUD];
    
    // Set determinate mode
    self.HUD.mode = MBProgressHUDModeIndeterminate;
    self.HUD.delegate = self;
    self.HUD.labelText = @"Uploading...";
    [self.HUD show:YES];
    
    CLLocation *currentLocation = [self.dataSource currentLocationForThrowViewController:self];
    CLPlacemark *currentPlacemark = [self.dataSource currentPlacemarkForThrowViewController:self];
    CLLocationCoordinate2D currentCoordinate = currentLocation.coordinate;
    
    NSMutableArray *image = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [self.images count]; i++) {
        NSData *imageData = UIImageJPEGRepresentation(self.images[i], 0.7);
        NSString *imageName = [NSString stringWithFormat:@"%@.jpg", self.titleField.text];
        imageName = [imageName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        NSLog(@"%@", imageName);
        
        PFFile *file = [PFFile fileWithName: imageName  data:imageData];
        
        [image addObject:file];
    }
    
    PFGeoPoint *currentPoint =
    [PFGeoPoint geoPointWithLatitude:currentCoordinate.latitude
                           longitude: currentCoordinate.longitude
     ];
    
    PFObject *postObject = [PFObject objectWithClassName: PartayParsePostClassName];
    postObject[PartayParsePostUserKey] = [PFUser currentUser];
    postObject[PartayParsePostTitleKey] = self.titleField.text;
    postObject[PartayParsePostLocationKey] = currentPoint;
    postObject[PartayParsePostTextKey] = self.aboutField.text;
    postObject[PartayParsePostLocalityKey] = currentPlacemark.locality;
    postObject[PartayParsePostStartDateKey] = self.dateInputField.text;
    postObject[PartayParsePostPrivateKey] = (self.publicChecked) ? @"False" : @"True";
    postObject[PartayParsePostPublicKey] = (self.privateChecked) ? @"False" : @"True";
    postObject[PartayParsePostPaidKey] = (self.paidChecked) ? @"False" : @"True";
    
    if ([image count] > 0) {
        postObject[PartayParsePostImageOneKey] = [image objectAtIndex: 0];
       
    }
    if ([image count] > 1) {
        postObject[PartayParsePostImageTwoKey] = [image objectAtIndex: 1];
    }
    if ([image count] > 2) {
        postObject[PartayParsePostImageThreeKey] = [image objectAtIndex: 2];
    }
    
    //This needs to be redone in a much smarter way.
    if(self.imageOne.image != nil) {
        NSData *thumbnail = UIImageJPEGRepresentation([self generatePhotoThumbnail:self.imageOne.image], 0.7);
        NSString *imageName = [NSString stringWithFormat:@"th_%@.jpg", self.titleField.text];
        imageName = [imageName stringByReplacingOccurrencesOfString:@" " withString:@"-"];
        PFFile *thumb = [PFFile fileWithName:imageName data:thumbnail];
        postObject[PartayParsePostThumbnailKey] = thumb;
        
    } else if(self.imageTwo.image != nil) {
        NSData *thumbnail = UIImageJPEGRepresentation([self generatePhotoThumbnail:self.imageTwo.image], 0.7);
        NSString *imageName = [NSString stringWithFormat:@"th_%@.jpg", self.titleField.text];
        imageName = [imageName stringByReplacingOccurrencesOfString:@" " withString:@"-"];
        PFFile *thumb = [PFFile fileWithName:imageName data:thumbnail];
        postObject[PartayParsePostThumbnailKey] = thumb;

    } else if(self.imageThree.image != nil) {
        NSData *thumbnail = UIImageJPEGRepresentation([self generatePhotoThumbnail:self.imageThree.image], 0.7);
        NSString *imageName = [NSString stringWithFormat:@"th_%@.jpg", self.titleField.text];
        imageName = [imageName stringByReplacingOccurrencesOfString:@" " withString:@"-"];
        PFFile *thumb = [PFFile fileWithName:imageName data:thumbnail];
        postObject[PartayParsePostThumbnailKey] = thumb;
    }
    
    PFACL *readOnlyACL = [PFACL ACL];
    [readOnlyACL setPublicReadAccess:YES];
    [readOnlyACL setPublicWriteAccess:NO];
       postObject.ACL = readOnlyACL;
    
    [postObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {  // Failed to save, show an alert view with the error message
            UIAlertView *alertView =
            [[UIAlertView alloc] initWithTitle:[error userInfo][@"error"]
                                       message:nil
                                      delegate:self
                             cancelButtonTitle:nil
                             otherButtonTitles:@"Ok", nil];
            [alertView show];
            [self.HUD hide:YES];
            return;
        }
        if (succeeded) {  // Successfully saved, post a notification to tell other view controllers
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.HUD hide:YES];
                
                // Show checkmark
                self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
                [self.view addSubview: self.HUD];
                
                self.HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkBoxMarked.png"]];
                
                // Set custom view mode
                self.HUD.mode = MBProgressHUDModeCustomView;
                
                self.HUD.labelText = @"Completed!";
                
                [self.HUD hide:YES afterDelay:5];
                self.HUD.delegate = self;
                
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:PartayPartyThrownNotification
                 object:nil];
            });
        }
    }];
}

- (void) resetView {
    
}

#pragma mark - checkbox handlers

- (IBAction)publicCheckBoxButtonHandler:(id)sender {
    if (!self.privateChecked) {
        if(!self.publicChecked) {
            [self.publicCheckBoxButton setImage:[UIImage imageNamed:@"checkBoxMarked.png"] forState: UIControlStateNormal];
            self.publicChecked = YES;
        } else if (self.publicChecked){
            [self.publicCheckBoxButton setImage:[UIImage imageNamed:@"checkBox.png"] forState: UIControlStateNormal];
            self.publicChecked = NO;
        }
    }
    
}

- (IBAction)privateCheckBoxButtonHandler:(id)sender {
    if (!self.publicChecked) {
        if(!self.privateChecked) {
            [self.privateCheckBoxButton setImage:[UIImage imageNamed:@"checkBoxMarked.png"] forState: UIControlStateNormal];
            self.privateChecked = YES;
        } else if (self.privateChecked){
            [self.privateCheckBoxButton setImage:[UIImage imageNamed:@"checkBox.png"] forState: UIControlStateNormal];
            self.privateChecked = NO;
        }
    }
}

- (IBAction)paidButtonHandler:(id)sender {
    if(!self.paidChecked) {
        [self.paidButton setImage:[UIImage imageNamed:@"checkBoxMarked.png"] forState: UIControlStateNormal];
        self.paidChecked = YES;
    } else if (self.paidChecked){
        [self.paidButton setImage:[UIImage imageNamed:@"checkBox.png"] forState: UIControlStateNormal];
        self.paidChecked = NO;
    }
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    self.aboutField.text = @"";
    self.aboutField.textColor = [UIColor blackColor];
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{
    
    if(self.aboutField.text.length == 0){
        self.aboutField.textColor = [UIColor lightGrayColor];
        self.aboutField.text = @"About";
        [self.aboutField resignFirstResponder];
    }
}

#pragma mark - image tap recognizer

- (IBAction)imageOneTapHandler:(UITapGestureRecognizer *)sender {
    self.lastImagePressed = self.imageOne;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle: nil
                                                             delegate: self
                                                    cancelButtonTitle: @"Cancel"
                                               destructiveButtonTitle: nil
                                                    otherButtonTitles: @"Photo library", @"Camera", nil];
    [actionSheet showInView:self.view];
}

- (IBAction)imageTwoTapHandler:(UITapGestureRecognizer *)sender {
    self.lastImagePressed = self.imageTwo;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle: nil
                                                             delegate: self
                                                    cancelButtonTitle: @"Cancel"
                                               destructiveButtonTitle: nil
                                                    otherButtonTitles: @"Photo library", @"Camera", nil];
    [actionSheet showInView:self.view];

}

- (IBAction)imageThreeTapHandler:(UITapGestureRecognizer *)sender {
    self.lastImagePressed = self.imageThree;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle: nil
                                                             delegate: self
                                                    cancelButtonTitle: @"Cancel"
                                               destructiveButtonTitle: nil
                                                    otherButtonTitles: @"Photo library", @"Camera", nil];
    [actionSheet showInView:self.view];

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
        controller.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypeCamera];
        controller.delegate = self;
        [self.navigationController presentViewController: controller animated: YES completion: nil];
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
        controller.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypePhotoLibrary];
        controller.delegate = self;
        [self.navigationController presentViewController: controller animated: YES completion: nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.lastImagePressed.image = chosenImage;
    
    [self.images addObject:chosenImage];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

-(UIImage *)generatePhotoThumbnail:(UIImage *)image
{
    CGSize size = image.size;
    CGSize croppedSize;
    CGFloat ratio = 75.0;
    CGFloat offsetX = 0.0;
    CGFloat offsetY = 0.0;
    
    if (size.width > size.height) {
        offsetX = (size.height - size.width) / 2;
        croppedSize = CGSizeMake(size.height, size.height);
    } else
    {
        offsetY = (size.width - size.height) / 2;
        croppedSize = CGSizeMake(size.width, size.width);
    }
    
    CGRect clippedRect = CGRectMake(offsetX * -1, offsetY * -1, croppedSize.width, croppedSize.height);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], clippedRect);
    
    CGRect rect = CGRectMake(0.0, 0.0, ratio, ratio);
    
    UIGraphicsBeginImageContext(rect.size);
    [[UIImage imageWithCGImage:imageRef] drawInRect:rect];
    UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRelease(imageRef);
    
    return thumbnail;
}

#pragma mark - MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [self.HUD removeFromSuperview];
    self.HUD = nil;
}

@end
