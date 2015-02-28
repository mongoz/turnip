//
//  ThrowViewController.m
//  turnip
//
//  Created by Per on 1/4/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "ThrowViewController.h"
#import "AppDelegate.h"
#import <CoreData/CoreData.h>
#import <Parse/Parse.h>
#import "Constants.h"
#import "SWRevealViewController.h"
#import "ThrowNextViewController.h"


@interface ThrowViewController ()

@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) CLPlacemark *placemark;

@property (nonatomic, strong) NSArray *currentEvent;
@property (nonatomic, strong) NSString *currentEventId;
@property (nonatomic, assign) BOOL isPrivate;
@property (nonatomic, assign) BOOL isFree;
@property (nonatomic, assign) BOOL update;

@end

@implementation ThrowViewController

- (void) viewWillAppear:(BOOL)animated {
    [self.tabBarController.tabBar setHidden:YES];
    self.navigationItem.hidesBackButton = YES;
    
    if ([self.currentEvent count] == 0) {
        self.currentEvent = [[NSArray alloc] initWithArray:[self loadCoreData]];
        if ([self.currentEvent count] > 0) {
            [self performSegueWithIdentifier:@"revealSegue" sender:self];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    self.isPrivate = YES;
    self.isFree = YES;
    
}

#pragma mark setup view methods

- (void) setupView {
    
    self.update = NO;
    
    self.aboutField.text = @"About";
    self.aboutField.textColor = [UIColor blackColor];
    self.aboutField.delegate = self;
    
    self.currentLocation = [self.dataSource currentLocationForThrowViewController:self];
    [self reverseGeocode: self.currentLocation];
    
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
            [self.aboutField.text isEqual: @""] ||
            [self.locationField.text isEqual: @""]);
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


#pragma mark - navigation

- (BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
    if ([identifier isEqualToString:@"nextThrowSegue"] && ![self checkInput]) {
        return YES;
    } else {
        UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:@"error"
                                   message:@"You have not filled in all the required fields."
                                  delegate:self
                         cancelButtonTitle:nil
                         otherButtonTitles:@"Ok", nil];
        [alertView show];
    }
    
    return NO;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"revealSegue"]) {
        SWRevealViewController *destViewController = (SWRevealViewController *) segue.destinationViewController;
        
        destViewController.currentEvent = self.currentEvent;
    }
    
    if ([segue.identifier isEqualToString:@"nextThrowSegue"]) {
        ThrowNextViewController *destViewController = (ThrowNextViewController *) segue.destinationViewController;
        
        destViewController.name = self.titleField.text;
        destViewController.location = self.locationField.text;
        destViewController.about = self.aboutField.text;
        destViewController.isPrivate = self.isPrivate;
        destViewController.isFree = self.isFree;
        destViewController.coordinates = self.currentLocation;
        destViewController.placemark = self.placemark;
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        destViewController.cost = [numberFormatter numberFromString: self.cashAmountField.text];;
        
    }
}

- (IBAction)unwindToThrow:(UIStoryboardSegue*)sender
{
    // Pull any data from the view controller which initiated the unwind segue.
}

#pragma mark - Notifications

- (void)eventWasDeleted:(NSNotification *)note {
    self.currentLocation = [self.dataSource currentLocationForThrowViewController:self];
    [self reverseGeocode: self.currentLocation];
}


@end
