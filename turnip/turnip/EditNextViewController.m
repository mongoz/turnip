//
//  EditNextViewController.m
//  turnip
//
//  Created by Per on 3/10/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "EditNextViewController.h"
#import "AppDelegate.h"
#import <CoreData/CoreData.h>
#import "Constants.h"
#import "DateTimePicker.h"
#import <Parse/Parse.h>
#import "TurnipEvent.h"

@interface EditNextViewController ()

@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) NSDate *selectedTime;
@property (nonatomic, strong) DateTimePicker *datePicker;
@property (nonatomic, strong) DateTimePicker *endTimePicker;

@property (nonatomic, strong) UIImageView *lastImagePressed;
@property (nonatomic, strong) NSMutableArray *images;

@property (nonatomic, strong) NSString *currentEventId;

@end

@implementation EditNextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initView];
    [self initPickerViews];
    [self setupViews];
    
    NSLog(@"navigationStack %@", self.navigationController.viewControllers);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initView {
    self.selectedDate = [NSDate new];
    
    self.images = [[NSMutableArray alloc] init];
    
    self.imageOne.userInteractionEnabled = YES;
    self.imageTwo.userInteractionEnabled = YES;
    self.imageThree.userInteractionEnabled = YES;
    
    self.capacityInputField.delegate = self;
    self.capacityInputField.keyboardType = UIKeyboardTypeNumberPad;
    
    UIToolbar *numberToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolBar.barStyle = UIBarStyleBlackTranslucent;
    numberToolBar.items = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)],
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)], nil];
    [numberToolBar sizeToFit];
    self.capacityInputField.inputAccessoryView = numberToolBar;
}

- (void) cancelNumberPad {
    [self.capacityInputField resignFirstResponder];
    self.capacityInputField.text = @"";
}

- (void) doneWithNumberPad {
    [self.capacityInputField resignFirstResponder];
}

- (void) initPickerViews {
    UIView *dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.day = 30;
    NSCalendar *theCalendar = [NSCalendar currentCalendar];
    NSDate *maxDate = [theCalendar dateByAddingComponents:dayComponent toDate:[NSDate date] options:0];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
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
        
    });
}

- (void) setupViews {
    self.imageOne.image = [[self.currentEvent valueForKey:@"image1"] objectAtIndex:0];
    if ([[self.currentEvent valueForKey:@"image2"] objectAtIndex:0] != [NSNull null]) {
        self.imageTwo.image = [[self.currentEvent valueForKey:@"image2"] objectAtIndex:0];
    }
    if ([[self.currentEvent valueForKey:@"image3"] objectAtIndex:0] != [NSNull null]) {
       self.imageThree.image = [[self.currentEvent valueForKey:@"image3"] objectAtIndex:0];
    }
   
    self.capacityInputField.text = [[[self.currentEvent valueForKey:@"capacity"] objectAtIndex:0] stringValue];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd hh:mm a";
    
    self.dateInputField.text = [dateFormatter stringFromDate: [[self.currentEvent valueForKey:@"date"] objectAtIndex:0]];
    self.endTimeDate.text = [[self.currentEvent valueForKey:@"endTime"] objectAtIndex:0];
}


#pragma mark - button handlers

- (IBAction) backButtonHandler:(id)sender {
    if(self.navigationController){
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction) saveButtonHandler:(id)sender {
    if (![self checkInput]) {
        
        self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview: self.HUD];
        
        // Set determinate mode
        self.HUD.mode = MBProgressHUDModeIndeterminate;
        self.HUD.delegate = self;
        self.HUD.labelText = @"Uploading...";
        [self.HUD show:YES];
        
        //       CLLocationCoordinate2D currentCoordinate = self.coordinates.coordinate;
        
        PFQuery *query = [PFQuery queryWithClassName:TurnipParsePostClassName];
        
        [query getObjectInBackgroundWithId:[[self.currentEvent valueForKey:@"objectId"] objectAtIndex:0] block:^(PFObject *eventData, NSError *error) {
            if(!error) {
                NSCharacterSet *special = [[NSCharacterSet letterCharacterSet] invertedSet];
                
                NSString *filtered = [self.name stringByTrimmingCharactersInSet:special];
                NSString *imageName = [NSString stringWithFormat:@"%@.jpg", filtered];
                imageName = [imageName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
                
                //        PFGeoPoint *currentPoint =
                //        [PFGeoPoint geoPointWithLatitude:currentCoordinate.latitude
                //                               longitude: currentCoordinate.longitude
                //         ];
                
                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                
                eventData[TurnipParsePostUserKey] = [PFUser currentUser];
                eventData[TurnipParsePostTitleKey] = self.name;
                //       postObject[TurnipParsePostLocationKey] = currentPoint;
                eventData[TurnipParsePostTextKey] = self.about;
                eventData[TurnipParsePostPrivateKey] = (self.isPrivate) ? @"True" : @"False";
                eventData[TurnipParsePostPaidKey] = (self.isFree) ? @"True" : @"False";
                //            postObject[@"address"] = [self.placemark.addressDictionary valueForKey:@"Street"];
                eventData[TurnipParsePostAddressKey] = self.location;
                eventData[TurnipParsePostDateKey] = self.selectedDate;
                eventData[TurnipParsePostEndTimeKey] = self.endTimeDate.text;
                eventData[TurnipParsePostCapacityKey] = [numberFormatter numberFromString:self.capacityInputField.text];
                eventData[TurnipParsePostPriceKey] = self.cost;
                
                if (self.imageOne.image == nil) {
                    [eventData removeObjectForKey:TurnipParsePostImageOneKey];
                } else {
                    NSData *imageData = UIImageJPEGRepresentation(self.imageOne.image, 0.7);
                    PFFile *file = [PFFile fileWithName:imageName  data:imageData];
                    eventData[TurnipParsePostImageOneKey] = file;
                }
                if (self.imageTwo.image == nil) {
                    NSLog(@"image two if");
                    [eventData removeObjectForKey:TurnipParsePostImageTwoKey];
                } else {
                    NSLog(@"image two else");
                    NSData *imageData = UIImageJPEGRepresentation(self.imageTwo.image, 0.7);
                    PFFile *file = [PFFile fileWithName:imageName  data:imageData];
                    eventData[TurnipParsePostImageTwoKey] = file;
                }
                if (self.imageThree.image == nil) {
                    NSLog(@"image three if");
                    [eventData removeObjectForKey:TurnipParsePostImageThreeKey];
                } else {
                    NSLog(@"image three else");
                    NSData *imageData = UIImageJPEGRepresentation(self.imageThree.image, 0.7);
                    PFFile *file = [PFFile fileWithName:imageName  data:imageData];
                    eventData[TurnipParsePostImageThreeKey] = file;
                }
                
                //This needs to be redone in a much smarter way.
                NSString *thumbImageName = [NSString stringWithFormat:@"th_%@.jpg", filtered];
                thumbImageName = [thumbImageName stringByReplacingOccurrencesOfString:@" " withString:@"-"];
                
                if(self.imageOne.image != nil) {
                    NSData *thumbnail = UIImageJPEGRepresentation([self generatePhotoThumbnail:self.imageOne.image], 0.7);
                    
                    PFFile *thumb = [PFFile fileWithName:thumbImageName data:thumbnail];
                    eventData[TurnipParsePostThumbnailKey] = thumb;
                    
                }
                
                [eventData saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
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
                            [[NSNotificationCenter defaultCenter] postNotificationName:TurnipPartyThrownNotification object:nil];
                            [self.HUD hide:YES];
                            
                            // Show checkmark
                            self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
                            [self.view addSubview: self.HUD];
                            
                            self.HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"yesButton"]];
                            
                            // Set custom view mode
                            self.HUD.mode = MBProgressHUDModeCustomView;
                            
                            self.HUD.labelText = @"Completed!";
                            
                            [self.HUD hide:YES afterDelay:5];
                            self.HUD.delegate = self;
                        });
                        [self saveToCoreData:eventData];
                        self.currentEventId = eventData.objectId;
                        [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:1] animated:YES];
                        [[NSNotificationCenter defaultCenter] postNotificationName:TurnipPartyUpdateNotification object:nil];
                    }
                }];
            } else {
                NSLog(@"fetch error: %@", error);
            }
            
        }];
    } else {
        if ([self.dateInputField.text isEqual: @""]) {
            self.dateInputField.layer.cornerRadius = 8.0f;
            self.dateInputField.layer.masksToBounds = YES;
            self.dateInputField.layer.borderWidth = 1.0f;
            self.dateInputField.layer.borderColor = [[UIColor redColor] CGColor];
        }
        
        if ([self.endTimeDate.text isEqual: @""]) {
            self.endTimeDate.layer.cornerRadius = 8.0f;
            self.endTimeDate.layer.masksToBounds = YES;
            self.endTimeDate.layer.borderWidth = 1.0f;
            self.endTimeDate.layer.borderColor = [[UIColor redColor] CGColor];
        }
        
        if ([self.capacityInputField.text isEqual: @""]) {
            self.capacityInputField.layer.cornerRadius = 8.0f;
            self.capacityInputField.layer.masksToBounds = YES;
            self.capacityInputField.layer.borderWidth = 1.0f;
            self.capacityInputField.layer.borderColor = [[UIColor redColor] CGColor];
        }
        
        if(self.imageOne.image == nil) {
            self.imageOne.layer.borderColor = [[UIColor redColor] CGColor];
        }
    }
}

#pragma mark -
#pragma mark textFieldDelegates

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.dateInputField) {
        self.selectedDate = [NSDate new];
        self.datePicker.hidden = NO;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MM/dd hh:mm a";
        
        self.dateInputField.text = [dateFormatter stringFromDate: self.selectedDate];
        
        if (self.dateInputField.layer.borderColor == [[UIColor redColor] CGColor]) {
            self.dateInputField.layer.borderColor = [[UIColor clearColor] CGColor];
        }
    }
    else if (textField == self.endTimeDate) {
        self.endTimePicker.hidden = NO;
        
        self.selectedTime = [NSDate date];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        dateFormatter.dateFormat = @"hh:mm a";
        
        self.endTimeDate.text = [dateFormatter stringFromDate: self.selectedTime];
        
        if (self.endTimeDate.layer.borderColor == [[UIColor redColor] CGColor]) {
            self.endTimeDate.layer.borderColor = [[UIColor clearColor] CGColor];
        }
    }
    
    else if (textField == self.capacityInputField && self.capacityInputField.layer.borderColor == [[UIColor redColor] CGColor]) {
        self.capacityInputField.layer.borderColor = [[UIColor clearColor] CGColor];
    }
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    
    if (textField == self.dateInputField) {
        self.datePicker.hidden = YES;
        [self.dateInputField resignFirstResponder];
    }
    else if (textField == self.endTimeDate) {
        if (self.endTimeDate.layer.borderColor == [[UIColor redColor] CGColor]) {
            self.endTimeDate.layer.borderColor = [[UIColor clearColor] CGColor];
        }
        self.endTimePicker.hidden = YES;
        [self.endTimePicker resignFirstResponder];
    }
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField == self.capacityInputField) {
        /* for backspace */
        if([string length]==0){
            return YES;
        }
        
        /*  limit to only numeric characters  */
        NSCharacterSet* numberCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        for (int i = 0; i < [string length]; ++i)
        {
            unichar c = [string characterAtIndex:i];
            if (![numberCharSet characterIsMember:c])
            {
                return NO;
            }
        }
        return YES;
    }
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.capacityInputField resignFirstResponder];
    
}

#pragma mark - Date/Time picker delegates

-(void)pickerChanged:(id)sender {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd hh:mm a";
    self.selectedDate = [sender date];
    
    self.dateInputField.text = [dateFormatter stringFromDate: self.selectedDate];
}

- (void) timePickerChanged: (id) sender {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    dateFormatter.dateFormat = @"hh:mm a";
    self.selectedTime = [sender date];
    self.endTimeDate.text = [dateFormatter stringFromDate: self.selectedTime];
    
    self.selectedTime = [dateFormatter dateFromString: self.endTimeDate.text];
    
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

#pragma mark - image tap recognizer

- (IBAction)imageOneTapHandler:(UITapGestureRecognizer *)sender {
    self.lastImagePressed = self.imageOne;
    
    if (self.imageOne.layer.borderColor == [[UIColor redColor] CGColor]) {
        self.imageOne.layer.borderColor = [[UIColor clearColor] CGColor];
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle: nil
                                                             delegate: self
                                                    cancelButtonTitle: @"Cancel"
                                               destructiveButtonTitle: nil
                                                    otherButtonTitles: @"Photo library", @"Camera",@"Remove Image", nil];
    [actionSheet showInView:self.view];
    
    self.imageTwo.hidden = NO;
}

- (IBAction)imageTwoTapHandler:(UITapGestureRecognizer *)sender {
    self.lastImagePressed = self.imageTwo;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle: nil
                                                             delegate: self
                                                    cancelButtonTitle: @"Cancel"
                                               destructiveButtonTitle: nil
                                                    otherButtonTitles: @"Photo library", @"Camera",@"Remove Image", nil];
    [actionSheet showInView:self.view];
    self.imageThree.hidden = NO;
    
}

- (IBAction)imageThreeTapHandler:(UITapGestureRecognizer *)sender {
    self.lastImagePressed = self.imageThree;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle: nil
                                                             delegate: self
                                                    cancelButtonTitle: @"Cancel"
                                               destructiveButtonTitle: nil
                                                    otherButtonTitles: @"Photo library", @"Camera", @"Remove Image", nil];
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
            break;
        case 2:
            self.lastImagePressed.image = nil;
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


#pragma mark Core Data

- (void) saveToCoreData :(PFObject *) postObject {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [delegate managedObjectContext];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    
    if ([self.currentEvent count] > 0) {
        NSManagedObject *managedObject = [self.currentEvent objectAtIndex:0];
        
        [managedObject setValue: self.name forKey:@"title"];
        [managedObject setValue: postObject.objectId forKey:@"objectId"];
        [managedObject setValue: self.about forKey:@"text"];
        [managedObject setValue: self.location forKey:@"location"];
        [managedObject setValue: self.selectedDate forKey:@"date"];
        [managedObject setValue: self.endTimeDate.text forKey:@"endTime"];
        [managedObject setValue: self.imageOne.image forKey:@"image1"];
        [managedObject setValue: self.imageTwo.image forKey:@"image2"];
        [managedObject setValue: self.imageThree.image forKey:@"image3"];
        [managedObject setValue: [numberFormatter numberFromString:self.capacityInputField.text] forKey:@"capacity"];

        NSNumber *privateAsNumber = [NSNumber numberWithBool: self.isPrivate];
        [managedObject setValue: privateAsNumber forKey:@"private"];
        
        NSNumber *freeAsNumber = [NSNumber numberWithBool: self.isFree];
        [managedObject setValue: freeAsNumber forKey:@"free"];
        
    }
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Error:%@", error);
    }
    NSLog(@"Event saved");
}

#pragma mark -
#pragma mark Utils

- (BOOL) checkInput {
    
    return ([self.dateInputField.text isEqual: @""] ||
            [self.endTimeDate.text isEqual: @"About..."] ||
            [self.capacityInputField.text isEqual: @""] ||
            self.imageOne.image == nil);
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
