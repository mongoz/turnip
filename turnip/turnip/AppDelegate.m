//
//  AppDelegate.m
//  partay
//
//  Created by Per on 1/4/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "AppDelegate.h"
#import "SAEMapViewController.h"
#import <ParseCrashReporting/ParseCrashReporting.h>
#import <CoreData/CoreData.h>
#import <Parse/Parse.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <GoogleMaps/GoogleMaps.h>
#import "Constants.h"
#import <Reachability.h>
#import "ReachabilityManager.h"
#import "SAEHostDetailsViewController.h"
#import "SAEUtilityFunctions.h"

#import <Stripe/Stripe.h>

#define  STRIPE_TEST_PUBLIC_KEY @"pk_test_DbMmTlz56j1vq6YhfoCZiXBS"

@interface AppDelegate ()

@property (nonatomic, strong) UIStoryboard *storyboard;
@property (nonatomic, assign) NSInteger notificationCount;
@property (nonatomic, assign) NSInteger messageCount;

@end

@implementation AppDelegate

@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize currentEvent = _currentEvent;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self managedObjectContext];
    
    [ReachabilityManager sharedManager];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetBadgeCount:) name:TurnipResetBadgeCountNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetMessageCount:) name:TurnipResetMessageBadgeCount object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationCounter:) name:TurnipGoToPublicPartyNotification object:nil];
        
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    
    self.storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    // Google Maps Api Key
    [GMSServices provideAPIKey:@"AIzaSyA4QJU6IPnOSOdPoc0CA1No1Ng0GukJn-8"];
    
    // [Optional] Power your app with Local Datastore. For more info, go to
    // https://parse.com/docs/ios_guide#localdatastore/iOS
    //[Parse enableLocalDatastore];
    
    [ParseCrashReporting enable];
    
    // Initialize Parse.
    [Parse setApplicationId:@"CJ2nRu0kVksgPXZjE38Cyhksns2PFckOwq6c9c64"
                 clientKey:@"UWt8D4lmGKO6Yr2axtpq68aJitE4Iy4ceH7A10GW"];
    
    
    [Stripe setDefaultPublishableKey: STRIPE_TEST_PUBLIC_KEY];
    //Dev client of Parse
     //[Parse setApplicationId:@"SfQvQqR6vQvkluA56LfqKl2qrkd32xKWcfoMoWng"
       //           clientKey:@"8hG06KY34D9hH8Ll079cQZPhVHWdC3dCBuiFPwiN"];
    
    [PFUser enableRevocableSessionInBackground];
    
    // [Optional] Track statistics around application opens.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    
    
    if(application.applicationState != UIApplicationStateBackground) {
        BOOL preBackgroundPush = ![application respondsToSelector:@selector(backgroundRefreshStatus)];
        BOOL oldPushHandlerOnly = ![self respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)];
        BOOL noPushPayload = ![launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
            [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
        }
    }
//    UIImage *backImage = [SAEUtilityFunctions imageResize:[UIImage imageNamed:@"backNav"] andResizeTo:CGSizeMake(30, 30)];
//    [[UIBarButtonItem appearanceWhenContainedIn:[UIImagePickerController class], nil] setBackButtonBackgroundImage:backImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 1);
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.549 green:0 blue:0.102 alpha:1]];
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], NSForegroundColorAttributeName, shadow, NSShadowAttributeName, [UIFont fontWithName:@"LemonMilk" size:20.0], NSFontAttributeName, nil]];
    
    Reachability *reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    if ([reachability isReachable]) {
        if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
            // Present map straight-away
            
            if ([[PFUser currentUser][@"TOS"] isEqualToString:@"True"]) {
                [self presentMapViewControllerAnimated:NO];
            } else {
                [self presentAcceptTosViewController];
            }

        } else {
            // Go to the welcome screen and have them log in or create an account.
            [self presentLoginViewController];
        }
    } else {
        [self presentLoginViewController];
        //[self presentAddressViewController];
    }
    return [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    // Logs 'install' and 'app activate' App Events.
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark push notifications

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackground];
}


-(void) application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Push registration error: %@", error);
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    if (application.applicationState == UIApplicationStateActive) {
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
    
    UITabBarController *tabController = (UITabBarController *) self.window.rootViewController;
    
    NSString *type = [userInfo objectForKey:@"type"];
    
    if ([type isEqualToString:@"eventRequest"]) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:TurnipPartyRequestPushNotification
         object:self];
        
        if ([[tabController.viewControllers objectAtIndex: TurnipTabNotification] tabBarItem].badgeValue != nil) {
            self.notificationCount = [[[tabController.viewControllers objectAtIndex: TurnipTabNotification] tabBarItem].badgeValue intValue];
        }

        self.notificationCount += 1;
        
        [[tabController.viewControllers objectAtIndex: TurnipTabNotification] tabBarItem].badgeValue = [NSString stringWithFormat:@"%ld", (long) self.notificationCount];
    }
    
    if([type isEqualToString:@"eventAccepted"]) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName: TurnipAcceptedRequestNotification
         object:self];
        
        if ([[tabController.viewControllers objectAtIndex: TurnipTabNotification] tabBarItem].badgeValue != nil) {
            self.notificationCount = [[[tabController.viewControllers objectAtIndex: TurnipTabNotification] tabBarItem].badgeValue intValue];
        }
        
        self.notificationCount += 1;
        
        [[tabController.viewControllers objectAtIndex:TurnipTabNotification] tabBarItem].badgeValue = [NSString stringWithFormat:@"%ld", (long) self.notificationCount];
    }
    
    if ([type isEqualToString:@"messagePush"]) {
        
        if ([[tabController.viewControllers objectAtIndex: TurnipTabMessage] tabBarItem].badgeValue != nil) {
            self.messageCount = [[[tabController.viewControllers objectAtIndex: TurnipTabMessage] tabBarItem].badgeValue intValue];
        }
        
        self.messageCount +=1;
        [[NSNotificationCenter defaultCenter] postNotificationName:TurnipMessagePushNotification object:userInfo];
        
        [[tabController.viewControllers objectAtIndex:TurnipTabMessage] tabBarItem].badgeValue = [NSString stringWithFormat:@"%ld", (long) self.messageCount];
    }
}

- (BOOL) pushNotificationOnOrOff
{
    if ([UIApplication instancesRespondToSelector:@selector(isRegisteredForRemoteNotifications)]) {
        return ([[UIApplication sharedApplication] isRegisteredForRemoteNotifications]);
    } else {
        UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        return (types & UIRemoteNotificationTypeAlert);
    }
}

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings: (UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
        NSLog(@"decline");
    }
    else if ([identifier isEqualToString:@"answerAction"]){
        NSLog(@"accept");
    }
}
#endif


#pragma mark - Notification delegates

- (void) resetBadgeCount:(NSNotification *)note {
    UITabBarController *tabController = (UITabBarController *) self.window.rootViewController;
    [[[[tabController tabBar] items] objectAtIndex: TurnipTabNotification] setBadgeValue:0];
    
    self.notificationCount = 0;
    
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"nrOfNotifications"];
    [[PFUser currentUser] saveInBackground];
}

- (void) notificationCounter:(NSNotification *)note {
    
    UITabBarController *tabController = (UITabBarController *) self.window.rootViewController;
    
    self.notificationCount += 1;
    [[tabController.viewControllers objectAtIndex:TurnipTabNotification] tabBarItem].badgeValue = [NSString stringWithFormat:@"%ld", (long) self.notificationCount];
    
    [PFUser currentUser][@"nrOfNotifications"] = @"0";
    
}

- (void) resetMessageCount:(NSNotification *) note {
    UITabBarController *tabController = (UITabBarController *) self.window.rootViewController;
    [[[[tabController tabBar] items] objectAtIndex: TurnipTabMessage] setBadgeValue:0];

    self.messageCount = 0;
    
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"nrOfMessages"];
    [[PFUser currentUser] saveInBackground];
}

#pragma mark facebook url open

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

#pragma mark -
#pragma mark LoginViewController

- (void)presentLoginViewController {
    // Go to the welcome screen and have them log in or create an account.
    UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loginView"];
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
}

#pragma mark -
#pragma mark acceptTosViewController

- (void)presentAcceptTosViewController {
    // Go to the welcome screen and have them log in or create an account.
    UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"acceptTosView"];
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
}

- (void)presentEventFeedViewController {
    // Go to the welcome screen and have them log in or create an account.
    UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"eventFeedView"];
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
}

#pragma mark -
#pragma mark MapViewController

- (void)presentMapViewControllerAnimated:(BOOL)animated {
    
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            
            UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"tabBar"];
            self.window.rootViewController = viewController;
            [self.window makeKeyAndVisible];
            
        } else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"]
                    isEqualToString: @"OAuthException"]) { // Since the request failed, we can check if it was due to an invalid session
            NSLog(@"The facebook session was invalidated");
            [PFFacebookUtils unlinkUserInBackground:[PFUser currentUser]];
        } else {
            NSLog(@"Some other error: %@", error);
        }
    }];
}

#pragma mark - Core Data stack
- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext {
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel {
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"TurnipDataModel" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"TurnipDataModel.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSDictionary *options = @{ NSMigratePersistentStoresAutomaticallyOption : @(YES),
                               NSInferMappingModelAutomaticallyOption : @(YES) };
    
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {

        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end