//
//  SAEAddressViewController.m
//  turnip
//
//  Created by Per on 6/2/15.
//  Copyright (c) 2015 Stupidest App Ever. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import "SAEAddressViewController.h"
#import "SAEUtilityFunctions.h"

@interface SAEAddressViewController()

@property (nonatomic, strong) GMSPlacesClient *placesClient;
@property (nonatomic, strong) NSMutableArray *addresses;
@property (nonatomic, strong) UITapGestureRecognizer *recognizer;

@end

@implementation SAEAddressViewController

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasHidden:) name:UIKeyboardDidHideNotification object:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"Address"];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 30.0f, 30.0f)];
    
    UIImage *backImage = [SAEUtilityFunctions imageResize:[UIImage imageNamed:@"backNav"] andResizeTo:CGSizeMake(30, 30)];
    [backButton setBackgroundImage:backImage  forState:UIControlStateNormal];
    [backButton setTitle:@"" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backNavigation) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
    self.recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touch)];
    
    [self.recognizer setNumberOfTapsRequired:1];
    [self.recognizer setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:self.recognizer];

    
    _addresses = [[NSMutableArray alloc] init];
    
    _searchBar.delegate = self;
    _placesClient = [[GMSPlacesClient alloc] init];
    
    //[self placeAutocomplete:@"2200 Colorado Ave"];
    
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.searchBar resignFirstResponder];
}


- (void) placeAutocomplete {
    
    [self.activityIndicator startAnimating];
    
    GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];
    filter.type = kGMSPlacesAutocompleteTypeFilterAddress;
    
    NSString *address = self.searchBar.text;
    
    [_placesClient autocompleteQuery:address
                              bounds:nil
                              filter:filter
                            callback: ^(NSArray *results, NSError *error) {
                                if (error != nil) {
                                    NSLog(@"Autocomplete error %@", [error localizedDescription]);
                                } else {
                                    [self.addresses removeAllObjects];
                                    for (GMSAutocompletePrediction *result in results) {
                                        
                                        [self.activityIndicator stopAnimating];
                                        [self.addresses addObject:result.attributedFullText.string];
                                     //   NSLog(@"results: %@", result.types);
                                        
                                    }
                                    [self.tableView reloadData];
                                }
        
    }];
}

#pragma mark - UISearchBar Delegates

-(void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    
    if (searchText != nil) {
        [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(placeAutocomplete) object:nil];
        [self performSelector:@selector(placeAutocomplete) withObject:nil afterDelay:1];

    }
    
    
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
}


#pragma mark - UITableView Delegates

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.addresses count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *tableIdentifier = @"addressCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableIdentifier];
    }
    
    NSArray *address = [[self.addresses objectAtIndex:indexPath.row] componentsSeparatedByString:@","];
    
    cell.textLabel.text = address[0];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@", address[1], address[2]];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *addr = [self.addresses objectAtIndex:indexPath.row];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addressChoosenNotification" object:addr];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Navigation

- (void)backNavigation {
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark - Notifications

- (void) keyboardWasShown: (NSNotification *) note {
    [self.recognizer setCancelsTouchesInView:YES];
    
}

- (void) keyboardWasHidden: (NSNotification *) note {
    [self.recognizer setCancelsTouchesInView:NO];
}

- (void) touch {
    
    [self.searchBar resignFirstResponder];
    
}

@end
