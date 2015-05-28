//
//  ThrowViewController.m
//  turnip
//
//  Created by Per on 1/4/15.
//  Copyright (c) 2015 Per. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "ThrowViewController.h"
#import "AppDelegate.h"
#import <CoreData/CoreData.h>
#import <Parse/Parse.h>
#import "Constants.h"
#import "SWRevealViewController.h"
#import "ThrowNextViewController.h"
#import "SAEHostDetailsViewController.h"

@interface ThrowViewController ()

@property (nonatomic, strong) ThrowNextViewController *nextViewController;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) CLLocation *eventLocation;
@property (nonatomic, strong) CLPlacemark *placemark;

@property (nonatomic, strong) NSString *oldAddress;
@property (nonatomic, strong) NSArray *currentEvent;
@property (nonatomic, strong) NSString *currentEventId;
@property (nonatomic, assign) BOOL isPrivate;
@property (nonatomic, assign) BOOL isFree;
@property (nonatomic, assign) BOOL update;
@property (nonatomic, assign) BOOL correctAddress;

@end

@implementation ThrowViewController

- (void) viewWillAppear:(BOOL)animated {
    [self.tabBarController.tabBar setHidden:YES];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    [self.navigationItem setHidesBackButton:YES animated:YES];
    
    if ([self.currentEvent count] == 0) {
        self.currentEvent = [[NSArray alloc] initWithArray:[self loadCoreData]];
    }
    if ([self.currentEvent count] > 0) {
        [self performSegueWithIdentifier:@"hostDetailsSegue" sender:self];
    }

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventWasDeleted:) name:TurnipEventDeletedNotification object:nil];
    
    [self setupView];
    self.isPrivate = YES;
    self.isFree = YES;
    
}

#pragma mark setup view methods

- (void) setupView {
    
    self.update = NO;
    
    self.titleField.delegate = self;
    self.locationField.delegate = self;
    
    self.aboutField.text = @"About...";
    self.aboutField.textColor = [UIColor blackColor];
    self.aboutField.delegate = self;
    
    [self.privateSwitch addTarget:self action:@selector(privateSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    [self.freeSwitch addTarget:self action:@selector(freeSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.cashAmountField.delegate = self;
    self.cashAmountField.keyboardType = UIKeyboardTypeNumberPad;
    
    UIToolbar *numberToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolBar.barStyle = UIBarStyleBlackTranslucent;
    numberToolBar.items = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)],
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)], nil];
    [numberToolBar sizeToFit];
    self.cashAmountField.inputAccessoryView = numberToolBar;

}

- (void) cancelNumberPad {
    [self.cashAmountField resignFirstResponder];
    self.cashAmountField.text = @"";
}

- (void) doneWithNumberPad {
    [self.cashAmountField resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)string {
    // Prevent crashing undo bug – see note below.
    if(range.length + range.location > self.aboutField.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [self.aboutField.text length] + [string length] - range.length;
    return (newLength > 140) ? NO : YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.titleField) {
        if(range.length + range.location > textField.text.length)
        {
            return NO;
        }
        
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return (newLength > 25) ? NO : YES;
    }
    
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.titleField resignFirstResponder];
    [self.aboutField resignFirstResponder];
    [self.locationField resignFirstResponder];
    [self.cashAmountField resignFirstResponder];
    
}

# pragma mark - button controll handlers
- (IBAction) backButtonHandler:(id)sender {
    [self.tabBarController.tabBar setHidden: NO];
    self.tabBarController.selectedIndex = 0;
}

- (IBAction) nextButtonHandler:(id)sender {
}

- (BOOL) checkInput {
    return ([self.titleField.text isEqual: @""] ||
            [self.aboutField.text isEqual: @"About..."] ||
            [self.locationField.text isEqual: @""] ||
            self.placemark == nil ||
            self.eventLocation == nil);
}


#pragma mark - Core Data

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

#pragma mark - switch handlers

- (void) privateSwitchChanged: (UISwitch *) switchState {
    if ([switchState isOn]) {
        self.isPrivate = NO;
    } else {
        self.isPrivate = YES;
    }
}

- (void) freeSwitchChanged: (UISwitch *) switchState {
    if ([switchState isOn]) {
        self.isFree = NO;
        self.cashAmountField.hidden = NO;
        self.cashLabel.hidden = NO;
    } else {
        self.isFree = YES;
        self.cashAmountField.hidden = YES;
        self.cashLabel.hidden = YES;
    }
}

#pragma mark - textfield handlers

- (void) textFieldDidEndEditing:(UITextField *)textField {
    if (self.locationField.text.length != 0 && ![self.oldAddress isEqualToString:self.locationField.text]) {
        self.oldAddress = self.locationField.text;
        [self forwardGeocoder:self.locationField.text];
    }
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.titleField && self.titleField.layer.borderColor == [[UIColor redColor] CGColor]) {
        self.titleField.layer.borderColor = [[UIColor clearColor] CGColor];
    }
    
    if (textField == self.locationField && self.locationField.layer.borderColor == [[UIColor redColor] CGColor]) {
        self.locationField.layer.borderColor = [[UIColor clearColor] CGColor];
    }
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    if ([self.aboutField.text isEqualToString:@"About..."]) {
        self.aboutField.text = @"";
        self.aboutField.textColor = [UIColor blackColor];
    }
    if (self.aboutField.layer.borderColor == [[UIColor redColor] CGColor]) {
        self.aboutField.layer.borderColor = [[UIColor clearColor] CGColor];
    }
    return YES;
}

- (void) textViewDidEndEditing:(UITextView *)textView {
    if(self.aboutField.text.length == 0){
        self.aboutField.textColor = [UIColor lightGrayColor];
        self.aboutField.text = @"About...";
        [self.aboutField resignFirstResponder];
    }
}

- (void)reverseGeocode:(CLLocation *)location {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"Error %@", error.description);
        } else {
            self.placemark = [placemarks lastObject];
        }
    }];
}

- (void) forwardGeocoder: (NSString *) address {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder geocodeAddressString:address inRegion:nil completionHandler:^(NSArray *placemarks, NSError *error) {
        for (CLPlacemark* aPlacemark in placemarks)
        {
            // Process the placemark.
            self.eventLocation = aPlacemark.location;
            self.placemark = [placemarks lastObject];
            
            NSLog(@"self.eventLocation : %@", self.eventLocation);
            NSLog(@"self.placemark : %@", self.placemark);
        }
    }];
}

#pragma mark - navigation

- (BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
    if (![self checkInput]) {
        if ([identifier isEqualToString:@"nextThrowSegue"]) {
            if (self.nextViewController) {
                self.nextViewController.name = self.titleField.text;
                self.nextViewController.location = self.locationField.text;
                self.nextViewController.about = self.aboutField.text;
                self.nextViewController.isPrivate = self.isPrivate;
                self.nextViewController.isFree = self.isFree;
                self.nextViewController.coordinates = self.eventLocation;
                self.nextViewController.placemark = self.placemark;
                
                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                if ([numberFormatter numberFromString: self.cashAmountField.text] == nil) {
                    NSNumber *price = [numberFormatter numberFromString: @"0"];
                    self.nextViewController.cost = price;
                } else {
                    NSNumber *price = [numberFormatter numberFromString: self.cashAmountField.text];
                    self.nextViewController.cost = price;
                }
                [self.navigationController pushViewController:self.nextViewController animated:YES];
                return NO;
            } else {
                return YES;
            }  
        }
    }
    else {
        if (self.placemark == nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid address"
                                                            message:@"The address you entered is invalid please double check it."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        
        if (self.titleField.text.length == 0) {
            self.titleField.layer.cornerRadius = 8.0f;
            self.titleField.layer.masksToBounds = YES;
            self.titleField.layer.borderWidth = 1.0f;
            self.titleField.layer.borderColor = [[UIColor redColor] CGColor];
        }
        if(self.locationField.text.length == 0) {
            self.locationField.layer.cornerRadius = 8.0f;
            self.locationField.layer.masksToBounds = YES;
            self.locationField.layer.borderWidth = 1.0f;
            self.locationField.layer.borderColor = [[UIColor redColor] CGColor];
        }
        if ([self.aboutField.text isEqualToString:@"About..."]) {
            self.aboutField.layer.cornerRadius = 8.0f;
            self.aboutField.layer.masksToBounds = YES;
            self.aboutField.layer.borderWidth = 1.0f;
            self.aboutField.layer.borderColor = [[UIColor redColor] CGColor];
        }
    }
    return NO;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"hostDetailsSegue"]) {
        
        SAEHostDetailsViewController *destViewController = (SAEHostDetailsViewController *) segue.destinationViewController;
        
        destViewController.event = [self.currentEvent objectAtIndex:0];
    }
    
    if ([segue.identifier isEqualToString:@"nextThrowSegue"]) {
        self.nextViewController = segue.destinationViewController;
        self.nextViewController.name = self.titleField.text;
        self.nextViewController.location = self.locationField.text;
        self.nextViewController.about = self.aboutField.text;
        self.nextViewController.isPrivate = self.isPrivate;
        self.nextViewController.isFree = self.isFree;
        self.nextViewController.coordinates = self.eventLocation;
        self.nextViewController.placemark = self.placemark;
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        if ([numberFormatter numberFromString: self.cashAmountField.text] == nil) {
            NSNumber *price = [numberFormatter numberFromString: @"0"];
             self.nextViewController.cost = price;

        } else {
            NSNumber *price = [numberFormatter numberFromString: self.cashAmountField.text];
             self.nextViewController.cost = price;
        }
    }
}

- (IBAction)unwindToThrow:(UIStoryboardSegue*)sender
{
    // Pull any data from the view controller which initiated the unwind segue.
}

#pragma mark - Notifications

- (void)eventWasDeleted:(NSNotification *)note {
    self.currentEvent = nil;
}

@end
