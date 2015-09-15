//
//  SAEThrowViewController.m
//  turnip
//
//  Created by Per on 1/4/15.
//  Copyright (c) 2015 Per. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "SAEThrowViewController.h"
#import "AppDelegate.h"
#import <CoreData/CoreData.h>
#import <Parse/Parse.h>
#import "Constants.h"
#import "SWRevealViewController.h"
#import "SAEThrowNextViewController.h"
#import "SAEHostDetailsViewController.h"

#define API_KEY @"AIzaSyCuVECTfnjZxMh8OdQgzOV4rClLfROUpOU"

@interface SAEThrowViewController ()

@property (nonatomic, strong) SAEThrowNextViewController *nextViewController;

@property (nonatomic, strong) SAEHostSingleton *event;

@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) CLLocation *eventLocation;
@property (nonatomic, strong) CLPlacemark *placemark;

@property (nonatomic, strong) NSString *oldAddress;
@property (nonatomic, strong) NSArray *currentEvent;
@property (nonatomic, strong) NSString *currentEventId;
@property (nonatomic, assign) BOOL isPrivate;
@property (nonatomic, assign) BOOL isFree;

@property (nonatomic, assign) BOOL correctAddress;

@property (nonatomic, strong) UITextField *activeField;
@property (nonatomic, strong) UITextView *activeTextView;


//Should probably make this into a custom object;
@property (nonatomic, strong) NSString *neighbourhood;
@property (nonatomic, strong) NSString *adminArea;
@property (nonatomic, strong) NSString *locality;

@end

@implementation SAEThrowViewController

- (void) viewWillAppear:(BOOL)animated {
    
    if ([self.currentEvent count] == 0) {
        self.currentEvent = [[NSArray alloc] initWithArray:[self loadCoreData]];
    }
    if ([self.currentEvent count] > 0) {
        [self performSegueWithIdentifier:@"hostDetailsSegue" sender:self];
    }

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"Host"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addressWasChoosen:) name:@"addressChoosenNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventWasDeleted:) name:TurnipEventDeletedNotification object:nil];
    self.currentLocation = [self.dataSource currentLocationForThrowViewController:self];
    
    [self setupView];
    self.isPrivate = YES;
    self.isFree = YES;
    
    self.event = [SAEHostSingleton sharedInstance];
    
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat view = self.view.frame.size.height;
    CGFloat content = self.contentView.frame.size.height;
    
    if (view > content) {
        [self.contentView setFrame:CGRectMake(0, 0, self.view.frame.size.height, view)];
    }
    
}


#pragma mark setup view methods

- (void) setupView {
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touch)];
    
    [recognizer setNumberOfTapsRequired:1];
    [recognizer setNumberOfTouchesRequired:1];
    [self.contentView addGestureRecognizer:recognizer];
    
    self.titleField.delegate = self;
    self.addressField.delegate = self;
    
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


# pragma mark - button controll handlers
- (IBAction) backButtonHandler:(id)sender {
    [self.tabBarController.tabBar setHidden: NO];
    self.tabBarController.selectedIndex = 0;
}

- (IBAction) nextButtonHandler:(id)sender {
    if (![self checkInput]) {
        self.event.title = self.titleField.text;
        self.event.address = self.addressField.text;
        self.event.text = self.aboutField.text;
        self.event.isPrivate = self.isPrivate;
        self.event.isFree = self.isFree;
        self.event.coordinates = self.eventLocation;
        self.event.neighbourhood = self.neighbourhood;
        self.event.host = [PFUser currentUser];
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        if ([numberFormatter numberFromString: self.cashAmountField.text] == nil) {
            NSNumber *price = [numberFormatter numberFromString: @"0"];
            self.event.price = price;
            
        } else {
            NSNumber *price = [numberFormatter numberFromString: self.cashAmountField.text];
            self.event.price = price;
        }

        [self performSegueWithIdentifier:@"hostImageSegue" sender:nil];
    }
    else {
        if (self.neighbourhood == nil) {
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
        if(self.addressField.text.length == 0) {
            self.addressField.layer.cornerRadius = 8.0f;
            self.addressField.layer.masksToBounds = YES;
            self.addressField.layer.borderWidth = 1.0f;
            self.addressField.layer.borderColor = [[UIColor redColor] CGColor];
        }
        if ([self.aboutField.text isEqualToString:@"About..."]) {
            self.aboutField.layer.cornerRadius = 8.0f;
            self.aboutField.layer.masksToBounds = YES;
            self.aboutField.layer.borderWidth = 1.0f;
            self.aboutField.layer.borderColor = [[UIColor redColor] CGColor];
        }
    }
}

- (BOOL) checkInput {
    return ([self.titleField.text isEqual: @""] ||
            [self.aboutField.text isEqual: @"About..."] ||
            [self.addressField.text isEqual: @""] ||
            self.adminArea == nil ||
            self.neighbourhood == nil);
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
        [self.scrollView setScrollEnabled:YES];
       
        
        [self scrollViewToBottom];
    } else {
        self.isFree = YES;
        self.cashAmountField.hidden = YES;
        self.cashLabel.hidden = YES;
        [self.scrollView setScrollEnabled:NO];
        [self.scrollView setContentOffset:CGPointMake(0, -self.scrollView.contentInset.top) animated:YES];
    }
}

#pragma mark - textfield handlers

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.addressField) {
        if ([self.titleField isFirstResponder]) {
            [self.titleField resignFirstResponder];
        }
        [self.addressField resignFirstResponder];
        [self performSegueWithIdentifier:@"showAddressView" sender:nil];
        return NO;
    }
    return YES;
}


- (void) textFieldDidBeginEditing:(UITextField *)textField {
    self.activeField = textField;
    
    if (textField == self.titleField && self.titleField.layer.borderColor == [[UIColor redColor] CGColor]) {
        self.titleField.layer.borderColor = [[UIColor clearColor] CGColor];
    }
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    self.activeField = nil;
}

#pragma mark - UITextView delegate

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView {
    if ([self.aboutField.text isEqualToString:@"About..."]) {
        self.aboutField.text = @"";
        self.aboutField.textColor = [UIColor blackColor];
    }
    if (self.aboutField.layer.borderColor == [[UIColor redColor] CGColor]) {
        self.aboutField.layer.borderColor = [[UIColor clearColor] CGColor];
    }
    return YES;
}

- (void) textViewDidBeginEditing:(UITextView *)textView {
    self.activeTextView = textView;
}

- (void) textViewDidEndEditing:(UITextView *)textView {
    self.activeTextView = nil;
    if(self.aboutField.text.length == 0){
        self.aboutField.textColor = [UIColor lightGrayColor];
        self.aboutField.text = @"About...";
        [self.aboutField resignFirstResponder];
    }
}

# pragma mark - Geocode

- (void) queryGoogleApi: (NSString *) address {
    
    NSString *addressString = [address stringByReplacingOccurrencesOfString:@" " withString: @"+"];
    NSArray *array = [address componentsSeparatedByString:@", " ];
    NSString *localityString = [array objectAtIndex:1];

    // https://maps.googleapis.com/maps/api/geocode/json?address=2200%20colorado%20ave&components=administrative_area:Los%20angeles%20county|country:US&key=AIzaSyCuVECTfnjZxMh8OdQgzOV4rClLfROUpOU
    NSString *urlAsString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?address=%@&components=country:US&key=%@",addressString, API_KEY ];
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            NSLog(@"error: %@", error);
        } else {
            NSError *localError;
             NSMutableArray *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            NSString *neighbourhood;
            
           NSArray *coords = [[[[jsonDict valueForKey:@"results"] valueForKey:@"geometry"] valueForKey:@"location"] objectAtIndex:0];
            self.eventLocation = [[CLLocation alloc] initWithLatitude:[[coords valueForKey:@"lat"] doubleValue] longitude:[[coords valueForKey:@"lng"] doubleValue]];
            
            for (NSArray *data in [[[jsonDict valueForKey:@"results"] valueForKey:@"address_components"] objectAtIndex:0]) {
                if ([[[data valueForKey:@"types"] objectAtIndex:0] isEqualToString:@"locality"]) {
                    self.locality = [data valueForKey:@"long_name"];
                }
                
                if ([[[data valueForKey:@"types"] objectAtIndex:0] isEqualToString:@"neighborhood"]) {
                    neighbourhood = [data valueForKey:@"long_name"];
                }
                
                if ([[[data valueForKey:@"types"] objectAtIndex:0] isEqualToString:@"administrative_area_level_2"]) {
                    self.adminArea = [data valueForKey:@"long_name"];
                }
                if (neighbourhood == nil && [[[data valueForKey:@"types"] objectAtIndex:0] isEqualToString:@"sublocality_level_1"]) {
                    neighbourhood = [data valueForKey:@"long_name"];
                }
            }
//            NSLog(@"----------------------------------");
//            NSLog(@"neigbourhood: %@", neighbourhood);
//            NSLog(@"locality: %@", self.locality);
//            NSLog(@"adminArea: %@", self.adminArea);
//            NSLog(@"----------------------------------");
            
            if([self.locality isEqualToString:@"Los Angeles"] && [self.locality isEqualToString:localityString]) {
                self.neighbourhood = neighbourhood;
            } else if ([neighbourhood isEqualToString:localityString]) {
                self.neighbourhood = neighbourhood;
            } else if([self.adminArea isEqualToString: @"Los Angeles County"]) {
                self.neighbourhood = self.locality;
            } else if(neighbourhood == nil) {
                self.neighbourhood = self.locality;
            } else {
                self.neighbourhood = neighbourhood;
            }
            
          //  NSLog(@"self.neigh %@", self.neighbourhood);
        }
    }];
}


#pragma mark - navigation

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"hostDetailsSegue"]) {
        
        SAEHostDetailsViewController *destViewController = (SAEHostDetailsViewController *) segue.destinationViewController;
        
        destViewController.event = [self.currentEvent objectAtIndex:0];
    }
    
    if([segue.identifier isEqualToString:@"hostImageSegue"]) {
        self.nextViewController = segue.destinationViewController;
        
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

- (void) addressWasChoosen: (NSNotification *) note {
    NSString *address = [note object];
    
    self.addressField.text = address;
    
    if ([self.addressField isFirstResponder]) {
        [self.addressField resignFirstResponder];
    }
    
    if ([self.titleField isFirstResponder]) {
        [self.titleField resignFirstResponder];
    }
    
    [self queryGoogleApi:address];
    
}

#pragma mark - scrollView

- (void) scrollViewToBottom {
    
     CGPoint bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height + self.scrollView.contentInset.bottom);
    [self.scrollView setContentOffset:bottomOffset animated:YES];
    
}

- (void) touch {
    
    [self.titleField resignFirstResponder];
    [self.aboutField resignFirstResponder];
    [self.addressField resignFirstResponder];
    [self.cashAmountField resignFirstResponder];
    
}

@end
