//
//  SAEHostAccessoriesViewController.m
//  turnip
//
//  Created by Per on 9/13/15.
//  Copyright (c) 2015 Stupidest App Ever. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreData/CoreData.h>
#import "ReachabilityManager.h"
#import <Parse/Parse.h>
#import "Constants.h"
#import "SAEHostAccessoriesViewController.h"
#import "SAEUtilityFunctions.h"

#define titleSize 58
#define descriptionSize 18

@interface SAEHostAccessoriesViewController () 

@property (nonatomic, strong) SAEHostSingleton *event;

@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) NSString *fontName;

@property (nonatomic, assign) NSInteger selectedFrame;
@property (nonatomic, assign) NSInteger selectedFont;

@property (nonatomic, strong) NSMutableArray *frames;
@property (nonatomic, strong) NSMutableArray *fonts;

@property (nonatomic, assign) BOOL fontColorPressed;


@end

@implementation SAEHostAccessoriesViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.fontColorPressed = NO;
    
    self.event = [SAEHostSingleton sharedInstance];
    
    self.frames = [[NSMutableArray alloc] init];
    self.fonts = [[NSMutableArray alloc] init];
    
    self.selectedFrame = 0;
    self.selectedFont = 0;
    
    self.textColor = [UIColor whiteColor];
    self.fontName = @"Helvetica Neue";
    
    [self buildFrameArray];
    [self buildFontArray];
    [self buildEventDescription];
    
    [self.hostImageView setImage:self.event.eventImage];
    
    CGSize size = self.view.bounds.size;
    
    CGSize wheelSize = CGSizeMake(size.width * .5, size.width * .5);
    
    self.colorWheel = [[ISColorWheel alloc] initWithFrame:CGRectMake(size.width / 2 - wheelSize.width / 2,
                                                                 size.height * .37,
                                                                 wheelSize.width,
                                                                 wheelSize.height)];
    
    self.colorWheel.delegate = self;
    self.colorWheel.continuous = true;
    self.colorWheel.hidden = YES;
    [self.view addSubview:self.colorWheel];
    
    _brightnessSlider = [[UISlider alloc] initWithFrame:CGRectMake(size.width * .25,
                                                                   size.height * .65,
                                                                   size.width * .5,
                                                                   size.height * .1)];
    
    _brightnessSlider.minimumValue = 0.0;
    _brightnessSlider.maximumValue = 1.0;
    _brightnessSlider.value = 1.0;
    _brightnessSlider.continuous = true;
    _brightnessSlider.hidden = YES;
    [_brightnessSlider addTarget:self action:@selector(changeBrightness:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_brightnessSlider];
    
     UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touch)];
    
    [recognizer setNumberOfTapsRequired:1];
    [recognizer setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:recognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Utils

- (void) touch {
    if (![self.colorWheel isHidden]) {
        self.colorWheel.hidden = YES;
        self.brightnessSlider.hidden = YES;
    }
}


- (void) buildEventDescription {
    
    NSString *title = [NSString stringWithFormat:@"%@\n", self.event.title];
    NSString *details = [NSString stringWithFormat:@"%@ \n %@ \n Price: $%@ \n", [self convertDate:self.event.startDate], self.event.text, self.event.price];
    
    if (!self.event.isPrivate) {
        details = [details stringByAppendingString: self.event.address];
    }
    
    self.titleLabel.textColor = self.textColor;
    self.descriptionLabel.textColor = self.textColor;
    
    self.titleLabel.font = [UIFont fontWithName:self.fontName size:titleSize];
    self.descriptionLabel.font = [UIFont fontWithName:self.fontName size:descriptionSize];
    
    self.titleLabel.text = title;
    self.descriptionLabel.text = details;
    
}

- (void) buildFontArray {
    
    [self.fonts addObject:@"Helvetica Neue"];
    [self.fonts addObject:@"QuicksandBook-Regular"];
    [self.fonts addObject:@"TypoSlab"];
    [self.fonts addObject:@"LemonMilk"];
    [self.fonts addObject:@"Gunplay-Regular"];
    [self.fonts addObject:@"Neon80s"];
    [self.fonts addObject:@"Biko"];
}


- (void) buildFrameArray {
    
    [self.frames addObject:[NSNull null]];
    for (int i = 1; i <= 5; i++) {
        NSString *imageName = [NSString stringWithFormat:@"border%d.png", i];
        UIImage *frame = [UIImage imageNamed:imageName];
        [self.frames addObject:frame];
    }
}

- (NSString *) convertDate:(NSDate *) date {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE MMMM dd, hh:mm a"];
    
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    return dateString;
}

- (UIImage *)captureView {
    
    //hide controls if needed
    CGRect rect = [self.hostImageView bounds];
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.view.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Button Handlers

- (IBAction)shareInstagramButton:(id)sender {
}

- (IBAction)shareFacebookButton:(id)sender {
}

- (IBAction)shareTwitterButton:(id)sender {
}

- (IBAction)shareButton:(id)sender {
}

- (IBAction)doneShareButton:(id)sender {
    
    [self performSegueWithIdentifier:@"eventFeedSegue" sender:nil];
}

- (IBAction)backNavigationButtonHandler:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)finishButtonHandler:(id)sender {
    
    if (![self.colorWheel isHidden]) {
        self.colorWheel.hidden = YES;
        self.brightnessSlider.hidden = YES;
    }
    
    UIImage *image = [self captureView];
    
    self.event.eventImage = image;
    
    [self saveToParse];
}

- (IBAction)frameColorButton:(id)sender {
    self.fontColorPressed = NO;
    
    if ([self.colorWheel isHidden]) {
        self.colorWheel.hidden = NO;
        self.brightnessSlider.hidden = NO;
    } else {
        self.colorWheel.hidden = YES;
        self.brightnessSlider.hidden = YES;
    }
}

- (IBAction)fontButton:(id)sender {
    self.selectedFont++;
    if (self.selectedFont == [self.fonts count]) {
        self.selectedFont = 0;
    }
    //reload text;
    [[self titleLabel] setFont:[UIFont fontWithName:[self.fonts objectAtIndex:self.selectedFont] size:titleSize]];
    [[self descriptionLabel] setFont:[UIFont fontWithName:[self.fonts objectAtIndex:self.selectedFont] size:descriptionSize]];
}

- (IBAction)frameButton:(id)sender {
    self.selectedFrame++;
    if (self.selectedFrame == [self.frames count]) {
        self.selectedFrame = 0;
    }
    if ([[self.frames objectAtIndex:self.selectedFrame] isEqual:[NSNull null]]) {
        [self.borderImageView setImage:nil];
    } else {
        [self.borderImageView setImage:[self.frames objectAtIndex:self.selectedFrame]];
    }

}

- (IBAction)textColorButton:(id)sender {
    self.fontColorPressed = YES;
    
    if ([self.colorWheel isHidden]) {
        self.colorWheel.hidden = NO;
        self.brightnessSlider.hidden = NO;
    } else {
        self.colorWheel.hidden = YES;
        self.brightnessSlider.hidden = YES;
    }
}

#pragma mark - ISColorWheelDelegate
- (void)changeBrightness:(UISlider*)sender {
    [_colorWheel setBrightness:_brightnessSlider.value];
}

- (void)colorWheelDidChangeColor:(ISColorWheel *)colorWheel {
    
    if (self.fontColorPressed) {
        self.titleLabel.textColor = _colorWheel.currentColor;
        self.descriptionLabel.textColor = _colorWheel.currentColor;
    } else {
        self.borderImageView.image = [self.borderImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.borderImageView setTintColor:_colorWheel.currentColor];
    }
    
}

#pragma mark - MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [self.HUD removeFromSuperview];
    self.HUD = nil;
}


#pragma mark Core Data

- (void) saveToCoreData: (PFObject *) object {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    NSManagedObject *dataRecord = [NSEntityDescription
                                   insertNewObjectForEntityForName:@"YourEvents"
                                   inManagedObjectContext: context];
    
    [dataRecord setValue: self.event.title forKey:@"title"];
    [dataRecord setValue: object.objectId forKey:@"objectId"];
    [dataRecord setValue: self.event.address forKey:@"location"];
    [dataRecord setValue: self.event.text forKey:@"text"];
    [dataRecord setValue: self.event.price forKey:@"price"];
    [dataRecord setValue: self.event.startDate forKey:@"date"];
    [dataRecord setValue: self.event.endDate forKey:@"endDate"];
    [dataRecord setValue: [[object objectForKey:@"neighbourhood"] valueForKey:@"name"] forKey:@"neighbourhood"];
    [dataRecord setValue: self.event.eventImage forKey:@"image"];

    NSNumber *privateAsNumber = [NSNumber numberWithBool: self.event.isPrivate];
    [dataRecord setValue: privateAsNumber forKey:@"private"];
    
    NSNumber *freeAsNumber = [NSNumber numberWithBool: self.event.isFree];
    [dataRecord setValue: freeAsNumber forKey:@"free"];
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Error:%@", error);
    }
    NSLog(@"Event saved");
    
}

- (void) saveImageToCameraRoll:(UIImage *) image {
    
}

- (void) saveToParse {
    if ([ReachabilityManager isReachable] ) {
        
        self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview: self.HUD];
        
        // Set determinate mode
        self.HUD.mode = MBProgressHUDModeIndeterminate;
        self.HUD.delegate = self;
        self.HUD.labelText = @"Throwing...";
        [self.HUD show:YES];
        
        CLLocationCoordinate2D currentCoordinate = self.event.coordinates.coordinate;
        
        NSCharacterSet *special = [[NSCharacterSet letterCharacterSet] invertedSet];
        NSString *filtered = [self.event.title stringByTrimmingCharactersInSet:special];
        
        PFGeoPoint *currentPoint =
        [PFGeoPoint geoPointWithLatitude:currentCoordinate.latitude
                               longitude: currentCoordinate.longitude
         ];
        
        PFObject *postObject = [PFObject objectWithClassName: TurnipParsePostClassName];
        postObject[TurnipParsePostUserKey] = [PFUser currentUser];
        postObject[TurnipParsePostTitleKey] = self.event.title;
        postObject[TurnipParsePostLocationKey] = currentPoint;
        postObject[TurnipParsePostTextKey] = self.event.text;
        postObject[TurnipParsePostPrivateKey] = (self.event.isPrivate) ? @"True" : @"False";
        postObject[TurnipParsePostPaidKey] = (self.event.isFree) ? @"True" : @"False";
        postObject[TurnipParsePostAddressKey] = self.event.address;
        postObject[TurnipParsePostDateKey] = self.event.startDate;
        postObject[@"endDate"] = self.event.endDate;
        postObject[TurnipParsePostPriceKey] = self.event.price;
        
        //This needs to be redone in a much smarter way.
        NSString *imageName = [NSString stringWithFormat:@"%@.jpg", filtered];
        imageName = [imageName stringByReplacingOccurrencesOfString:@" " withString:@"-"];
        
        NSData *imageData = UIImageJPEGRepresentation(self.event.eventImage, 1);
        
        PFFile *thumb = [PFFile fileWithName:imageName data:imageData];
        postObject[TurnipParsePostImageOneKey] = thumb;
        
        [PFCloud callFunctionInBackground:@"getNeighbourhood"
                           withParameters:@{@"neighbourhood": self.event.neighbourhood, @"adminArea": self.event.adminArea, @"locality": self.event.locality , @"isPrivate": (self.event.isPrivate) ? @"True" : @"False"}
                                    block:^(PFObject *neighbourhood, NSError *error) {
                                        if (!error) {
                                            postObject[@"neighbourhood"] = neighbourhood;
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
                                                        
                                                        [self saveToCoreData:postObject];
                                                        
                                                        [self.HUD hide:YES afterDelay:5];
                                                        self.HUD.delegate = self;
                                                        
                                                        self.shareView.hidden = NO;
                                                        self.event.saved = YES;
                                                        
                                                        [[NSNotificationCenter defaultCenter] postNotificationName:TurnipPartyThrownNotification object:nil];
                                                    });
                                                }
                                            }];
                                        } else {
                                            NSLog(@"error: %@", error);
                                        }
                                    }];
        
        //        PFACL *readOnlyACL = [PFACL ACL];
        //        [readOnlyACL setPublicReadAccess:YES];
        //        [readOnlyACL setWriteAccess:YES forUser:[PFUser currentUser]];
        //        postObject.ACL = readOnlyACL;
        
        
    } else {
        UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:@"Error: No Network"
                                   message:@"Could not connect to the server please try again later"
                                  delegate:self
                         cancelButtonTitle:nil
                         otherButtonTitles:@"Ok", nil];
        [alertView show];
        
    }
    
}


@end
