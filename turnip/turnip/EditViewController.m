//
//  EditViewController.m
//  turnip
//
//  Created by Per on 3/9/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreData/CoreData.h>
#import <Parse/Parse.h>
#import "Constants.h"
#import "EditViewController.h"
#import "EditNextViewController.h"


@interface EditViewController ()



@property (nonatomic, strong) EditNextViewController *nextViewController;
@property (nonatomic, strong) NSString *currentEventId;
@property (nonatomic, assign) BOOL isPrivate;
@property (nonatomic, assign) BOOL isFree;

@end

@implementation EditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self initViews];
    [self setupViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark setup view methods

- (void) initViews {
    
    self.titleField.delegate = self;
    self.locationField.delegate = self;
    
    self.aboutField.text = @"About...";
    self.aboutField.textColor = [UIColor blackColor];
    self.aboutField.delegate = self;
    
  //  self.currentLocation = [self.dataSource currentLocationForThrowViewController:self];
  //  [self reverseGeocode: self.currentLocation];
    
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

- (void) setupViews {
    self.titleField.text = [[self.currentEvent valueForKey:@"title"] objectAtIndex:0];
    self.locationField.text = [[self.currentEvent valueForKey:@"location"] objectAtIndex:0];
    self.aboutField.text = [[self.currentEvent valueForKey:@"text"] objectAtIndex:0];
    
    self.isPrivate = [[[self.currentEvent valueForKey:@"private"] objectAtIndex:0] boolValue];
    self.isFree = [[[self.currentEvent valueForKey:@"free"] objectAtIndex:0] boolValue];
    
    if (self.isPrivate) {
        [self.privateSwitch setOn:NO];
    } else {
        [self.privateSwitch setOn:YES];
    }
    
    if (self.isFree) {
        [self.freeSwitch setOn:NO];
    } else {
        [self.freeSwitch setOn:YES];
        self.cashAmountField.hidden = NO;
        self.cashLabel.hidden = NO;
    }
    
    if ([[self.currentEvent valueForKey:@"price"] objectAtIndex:0] != 0) {
        self.cashAmountField.text = [[[self.currentEvent valueForKey:@"price"] objectAtIndex:0] stringValue];
    }
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.titleField resignFirstResponder];
    [self.aboutField resignFirstResponder];
    [self.locationField resignFirstResponder];
    [self.cashAmountField resignFirstResponder];
    
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

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.titleField && self.titleField.layer.borderColor == [[UIColor redColor] CGColor]) {
        self.titleField.layer.borderColor = [[UIColor clearColor] CGColor];
    }
    
    if (textField == self.locationField && self.locationField.layer.borderColor == [[UIColor redColor] CGColor]) {
        self.locationField.layer.borderColor = [[UIColor clearColor] CGColor];
    }
}

#pragma mark - textfield handlers

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


# pragma mark - button controll handlers
- (IBAction) backButtonHandler:(id)sender {
    //TODO go back to detailsViewController.
    [self.tabBarController.tabBar setHidden: NO];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) nextButtonHandler:(id)sender {
    [self performSegueWithIdentifier:@"editNextPage" sender:self];
}

- (BOOL) checkInput {
    return ([self.titleField.text isEqual: @""] ||
            [self.aboutField.text isEqual: @"About..."] ||
            [self.locationField.text isEqual: @""]);
}


#pragma mark - Navigation
- (BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
    if (![self checkInput]) {
        if ([identifier isEqualToString:@"nextThrowSegue"]) {
            if (self.nextViewController) {
                [self.navigationController pushViewController:self.nextViewController animated:YES];
                return NO;
            } else {
                return YES;
            }
        }
    } else {
        
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

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"editNextPage"]) {
        self.nextViewController = (EditNextViewController *) segue.destinationViewController;
        
         self.nextViewController.currentEvent = self.currentEvent;
         self.nextViewController.name = self.titleField.text;
         self.nextViewController.location = self.locationField.text;
         self.nextViewController.about = self.aboutField.text;
         self.nextViewController.isPrivate = self.isPrivate;
         self.nextViewController.isFree = self.isFree;
//        destViewController.coordinates = self.currentLocation;
//        destViewController.placemark = self.placemark;
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        // NSNumber *price = [numberFormatter numberFromString: self.cashAmountField.text];
        if ([numberFormatter numberFromString: self.cashAmountField.text] == nil) {
            NSNumber *price = [numberFormatter numberFromString: @"0"];
             self.nextViewController.cost = price;
            
        } else {
            NSNumber *price = [numberFormatter numberFromString: self.cashAmountField.text];
             self.nextViewController.cost = price;
            
        }
    }

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

@end
