//
//  SAEPaymentViewController.m
//  turnip
//
//  Created by Per on 8/18/15.
//  Copyright (c) 2015 Stupidest App Ever. All rights reserved.
//

#import "SAEPaymentViewController.h"
#import "SAEStripeCard.h"
#import "SAEAddCardViewController.h"
#import "ProfileViewController.h"
#import "ParseErrorHandlingController.h"
#import <Parse/Parse.h>

@interface SAEPaymentViewController ()

@property (nonatomic, assign) BOOL newCustomer;
@property (nonatomic, strong) NSMutableArray *cards;

@end

@implementation SAEPaymentViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.newCustomer = YES;
    
    [self retriveCards];
}

- (void) retriveCards {
    PFQuery *query = [PFQuery queryWithClassName:@"Stripe"];
    
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error) {
            [ParseErrorHandlingController handleParseError: error];
        } else {
            self.newCustomer = NO;
            NSString *token = [object objectForKey:@"customerToken"];
            
            [PFCloud callFunctionInBackground:@"retriveCustomer"
                               withParameters:@{@"customerToken": token}
                                        block:^(id object, NSError *error) {
                                            if (!error) {

                                                [self buildCardArray:object];
                                                
                                            } else {
                                                NSLog(@"error: %@", error);
                                            }
                                        }];
        }
    }];
}

- (void) buildCardArray:(id) object {
    
    NSString *defaultSource = [object objectForKey:@"default_source"];
    
    self.cards = [[NSMutableArray alloc] init];
    
    for (NSArray *details in [[object objectForKey:@"sources"] objectForKey:@"data"]) {
        
        BOOL isDefault;
        if ([defaultSource isEqual:[details valueForKey:@"id"]]) {
            isDefault = YES;
        } else {
            isDefault = NO;
        }
    
        
        SAEStripeCard *card = [[SAEStripeCard alloc] initWithCardId:[details valueForKey:@"id"]
                                                             object:[details valueForKey:@"object"]
                                                              last4:[[details valueForKey:@"last4"] integerValue]
                                                              brand:[details valueForKey:@"brand"]
                                                            country:[details valueForKey:@"country"]
                                                        defaultCard:isDefault];
        [self.cards addObject:card];
    }
    
    [self.tableView reloadData];
    
}


#pragma mark - UITableView Delegates

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return [self.cards count];
            break;
        case 1:
            return 1;
            break;
        default:
            return 0;
            break;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return @"Your Cards";
            break;
        case 1:
            return @"Add Payment Method";
            break;
        default:
            return @"";
            break;
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *tableIdentifier = @"cardCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:tableIdentifier];
    }
    
    NSString * booleanString = ([[[self.cards valueForKey:@"defaultCard"] objectAtIndex:indexPath.row] boolValue]) ? @"Default" : @"";
    
    switch (indexPath.section) {
        case 0:
            cell.imageView.image = [UIImage imageNamed:@"email"];
            cell.textLabel.text = [[[self.cards valueForKey:@"last4"] objectAtIndex:indexPath.row] stringValue];
            cell.detailTextLabel.text = booleanString;
            break;
        case 1:
            cell.textLabel.text = @"Add Card";
            break;
        default:
            break;
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1 && indexPath.row == 0) {
        [self performSegueWithIdentifier:@"addCardSegue" sender:nil];
    }
}


#pragma mark - navigation

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"addCardSegue"]) {
        SAEAddCardViewController *destViewController = segue.destinationViewController;
        destViewController.newCustomer = self.newCustomer;
        
    }
}


- (IBAction)newCreditCardButton:(id)sender {
    [self performSegueWithIdentifier:@"addCardSeque" sender: nil];
}

- (IBAction)backNavigation:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    ProfileViewController *lvc = [storyboard instantiateViewControllerWithIdentifier:@"profileView"];
    [self.navigationController pushViewController:lvc animated:YES];
}

@end
