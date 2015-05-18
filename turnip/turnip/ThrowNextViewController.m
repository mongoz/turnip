//
//  ThrowNextViewController.m
//  turnip
//
//  Created by Per on 2/22/15.
//  Copyright (c) 2015 Per. All rights reserved.
//
#import "AppDelegate.h"
#import <CoreData/CoreData.h>
#import "Constants.h"
#import "ThrowNextViewController.h"
#import "DateTimePicker.h"
#import <Parse/Parse.h>
#import "SWRevealViewController.h"
#import "ReachabilityManager.h"
#import "HostDetailsViewController.h"

@interface ThrowNextViewController ()

@property (nonatomic, strong) NSArray *data;
@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) NSDate *selectedTime;
@property (nonatomic, strong) DateTimePicker *datePicker;
@property (nonatomic, strong) DateTimePicker *endTimePicker;

@property (nonatomic, strong) UIImageView *lastImagePressed;
@property (nonatomic, strong) NSMutableArray *images;

@property (nonatomic, strong) NSArray *currentEvent;
@property (nonatomic, strong) NSString *currentEventId;

@property (nonatomic, strong) UIImage *image;

@end

@implementation ThrowNextViewController

- (void) viewWillAppear:(BOOL)animated {
    
    // QUick fix change this to TurnipEvent thingy instead
    // read data Variable instead of coreData.
    self.currentEvent = [[NSArray alloc] initWithArray:[self loadCoreData]];
    if ([self.currentEvent count] > 0) {
        [self performSegueWithIdentifier:@"hostDetailsSegue" sender:self];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.image = [UIImage imageNamed:@"camera placeholder.png"];
    
    NSLog(@"placemark: %@", self.placemark);
    NSLog(@"coords: %@", self.coordinates);
    
    [self setupView];
    [self setupPickerViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setupView {
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

- (void) setupPickerViews {
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

#pragma mark -
#pragma mark textFieldDelegates

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.dateInputField) {
        self.selectedDate = [NSDate new];
        self.datePicker.hidden = NO;
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//        dateFormatter.dateFormat = @"MM/dd hh:mm a";
        
        self.dateInputField.text = [self convertDate:self.selectedDate];
        
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
    self.selectedDate = [sender date];
    
    self.dateInputField.text = [self convertDate: self.selectedDate];
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
    
}

- (IBAction)imageTwoTapHandler:(UITapGestureRecognizer *)sender {
    self.lastImagePressed = self.imageTwo;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle: nil
                                                             delegate: self
                                                    cancelButtonTitle: @"Cancel"
                                               destructiveButtonTitle: nil
                                                    otherButtonTitles: @"Photo library", @"Camera",@"Remove Image", nil];
    [actionSheet showInView:self.view];
    
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
    UIImageView *temp;
    
    NSLog(@"lastImagePressed %@", self.lastImagePressed);
    NSLog(@"temp %@", temp);
    self.lastImagePressed.image = chosenImage;
    
    //if ([temp isEqual:self.lastImagePressed]) {
        //NSLog(@"remove");
      //  [self.images removeLastObject];
    //}

    [self.images addObject:chosenImage];
    
   // temp = self.lastImagePressed;
    
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

- (BOOL) checkInput {
    
    return ([self.dateInputField.text isEqual: @""] ||
            [self.endTimeDate.text isEqual: @"About..."] ||
            [self.capacityInputField.text isEqual: @""] ||
            self.imageOne.image == nil);
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
        if ([ReachabilityManager isReachable] ) {
            
            self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview: self.HUD];
            
            // Set determinate mode
            self.HUD.mode = MBProgressHUDModeIndeterminate;
            self.HUD.delegate = self;
            self.HUD.labelText = @"Throwing...";
            [self.HUD show:YES];
            
            CLLocationCoordinate2D currentCoordinate = self.coordinates.coordinate;
            
            NSMutableArray *image = [[NSMutableArray alloc] init];
            NSCharacterSet *special = [[NSCharacterSet letterCharacterSet] invertedSet];
            
            NSString *filtered = [self.name stringByTrimmingCharactersInSet:special];
            
            for (int i = 0; i < [self.images count]; i++) {
                NSData *imageData = UIImageJPEGRepresentation(self.images[i], 0.7);
                
                NSString *imageName = [NSString stringWithFormat:@"%@.jpg", filtered];
                imageName = [imageName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
                
                PFFile *file = [PFFile fileWithName: imageName  data:imageData];
                
                [image addObject:file];
            }
            
            PFGeoPoint *currentPoint =
            [PFGeoPoint geoPointWithLatitude:currentCoordinate.latitude
                                   longitude: currentCoordinate.longitude
             ];
            
            PFObject *postObject = [PFObject objectWithClassName: TurnipParsePostClassName];
            postObject[TurnipParsePostUserKey] = [PFUser currentUser];
            postObject[TurnipParsePostTitleKey] = self.name;
            postObject[TurnipParsePostLocationKey] = currentPoint;
            postObject[TurnipParsePostTextKey] = self.about;
            postObject[TurnipParsePostLocalityKey] = self.placemark.locality;
            postObject[TurnipParsePostSubLocalityKey] = self.placemark.subLocality;
            postObject[TurnipParsePostZipCodeKey] = self.placemark.postalCode;
            postObject[TurnipParsePostPrivateKey] = (self.isPrivate) ? @"True" : @"False";
            postObject[TurnipParsePostPaidKey] = (self.isFree) ? @"True" : @"False";
            postObject[TurnipParsePostAddressKey] = self.location;
            postObject[TurnipParsePostDateKey] = self.selectedDate;
            postObject[TurnipParsePostEndTimeKey] = self.endTimeDate.text;
            postObject[TurnipParsePostPriceKey] = self.cost;
            
            if ([image count] > 0) {
                postObject[TurnipParsePostImageOneKey] = [image objectAtIndex: 0];
            }
            if ([image count] > 1) {
                postObject[TurnipParsePostImageTwoKey] = [image objectAtIndex: 1];
            }
            if ([image count] > 2) {
                postObject[TurnipParsePostImageThreeKey] = [image objectAtIndex: 2];
            }
            
            //This needs to be redone in a much smarter way.
            NSString *imageName = [NSString stringWithFormat:@"th_%@.jpg", filtered];
            imageName = [imageName stringByReplacingOccurrencesOfString:@" " withString:@"-"];
            
            if(self.imageOne.image != nil) {
                NSData *thumbnail = UIImageJPEGRepresentation([self generatePhotoThumbnail:self.imageOne.image], 0.7);
                
                PFFile *thumb = [PFFile fileWithName:imageName data:thumbnail];
                postObject[TurnipParsePostThumbnailKey] = thumb;
                
            }
            
            //        PFACL *readOnlyACL = [PFACL ACL];
            //        [readOnlyACL setPublicReadAccess:YES];
            //        [readOnlyACL setWriteAccess:YES forUser:[PFUser currentUser]];
            //        postObject.ACL = readOnlyACL;
            
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
                        [[NSNotificationCenter defaultCenter] postNotificationName:TurnipPartyThrownNotification object:nil];
                        [self.HUD hide:YES];
                        
                        // Show checkmark
                        self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
                        [self.view addSubview: self.HUD];
                        
                        self.HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"yesButton"]];
                        
                        // Set custom view mode
                        self.HUD.mode = MBProgressHUDModeCustomView;
                        
                        self.HUD.labelText = @"Completed!";
                        
                        [[postObject objectForKey:@"neighbourhood"] fetchIfNeeded];
                        [self saveToCoreData:postObject];
                        
                        [self.HUD hide:YES afterDelay:5];
                        self.HUD.delegate = self;
                        
                        self.currentEventId = postObject.objectId;
                        self.data = [[NSArray alloc] initWithObjects:postObject, nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:TurnipPartyThrownNotification object:nil];
                        [self viewWillAppear:YES];
                    });
                }
            }];
        } else {
            UIAlertView *alertView =
            [[UIAlertView alloc] initWithTitle:@"Error: No Network"
                                       message:@"Could not connect to the server please try again later"
                                      delegate:self
                             cancelButtonTitle:nil
                             otherButtonTitles:@"Ok", nil];
            [alertView show];

        }
   
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

#pragma mark Core Data

- (void) saveToCoreData:(PFObject *) postObject {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [delegate managedObjectContext];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    
   // NSLog(@"neighbourhood: %@", [[postObject objectForKey:@"neighbourhood"] valueForKey:@"name"]);
        
        NSManagedObject *dataRecord = [NSEntityDescription
                                       insertNewObjectForEntityForName:@"YourEvents"
                                       inManagedObjectContext: context];
        
        [dataRecord setValue: self.name forKey:@"title"];
        [dataRecord setValue: postObject.objectId forKey:@"objectId"];
        [dataRecord setValue: self.location forKey:@"location"];
        [dataRecord setValue: self.about forKey:@"text"];
        [dataRecord setValue: self.cost forKey:@"price"];
        [dataRecord setValue: self.selectedDate forKey:@"date"];
        [dataRecord setValue: self.endTimeDate.text forKey:@"endTime"];
        [dataRecord setValue: self.imageOne.image forKey:@"image1"];
        [dataRecord setValue: self.imageTwo.image forKey:@"image2"];
        [dataRecord setValue: self.imageThree.image forKey:@"image3"];
        [dataRecord setValue: [numberFormatter numberFromString:self.capacityInputField.text] forKey:@"capacity"];
        [dataRecord setValue: [[postObject objectForKey:@"neighbourhood"] valueForKey:@"name"] forKey:@"neighbourhood"];
    
        NSNumber *privateAsNumber = [NSNumber numberWithBool: self.isPrivate];
        [dataRecord setValue: privateAsNumber forKey:@"private"];
        
        NSNumber *freeAsNumber = [NSNumber numberWithBool: self.isFree];
        [dataRecord setValue: freeAsNumber forKey:@"free"];
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Error:%@", error);
    }
    NSLog(@"Event saved");
    
}

- (NSArray *) loadCoreData {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [delegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"YourEvents" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *fetchedObjects = [[NSArray alloc] initWithArray:[context executeFetchRequest:fetchRequest error: &error]];
    
    if ([fetchedObjects count] == 0) {
        return nil;
    } else {
        
        return fetchedObjects;
    }
    
}

#pragma mark - MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [self.HUD removeFromSuperview];
    self.HUD = nil;
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//     Get the new view controller using [segue destinationViewController].
//     Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"hostDetailsSegue"]) {
        
        HostDetailsViewController *destViewController = (HostDetailsViewController *)segue.destinationViewController;
        
        destViewController.event = [self.currentEvent objectAtIndex:0];
    }
}

#pragma mark -
#pragma mark utils

- (NSString *) convertDate: (NSDate *) date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    NSLocale *locale = [NSLocale currentLocale];
    [dateFormatter setLocale:locale];
    
    [dateFormatter setDoesRelativeDateFormatting:YES];
    
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    return dateString;
}

@end
