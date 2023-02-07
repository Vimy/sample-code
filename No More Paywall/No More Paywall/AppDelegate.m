//
//  AppDelegate.m
//  No More Paywall
//
//  Created by Matthias Vermeulen on 28/11/16.
//  Copyright © 2016 Matthias Vermeulen. All rights reserved.
//
#define RGB(r, g, b) [UIColor colorWithRed:(float)r / 255.0 green:(float)g / 255.0 blue:(float)b / 255.0 alpha:1.0]


#import "AppDelegate.h"
#import "OnboardingViewController.h"
#import "StoreManager.h"


@interface AppDelegate ()
@property (nonatomic, strong) NSURL *launchedURL;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    
    NSError *configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
        self.launchedURL = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
    
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : RGB(243, 150, 66) }
                                             forState:UIControlStateSelected];

    [[UITabBar appearance] setTintColor:RGB(243, 150, 66) ];
    [[UINavigationBar appearance] setTintColor:RGB(243, 150, 66) ];
    [[UINavigationBar appearance]  setTitleTextAttributes:@{NSForegroundColorAttributeName : RGB(243, 150, 66)}];
    
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    UIViewController *viewController;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:@"hasLaunchedBefore"])
    {
        viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"onboardingVC"];
            }
    else
    {
         viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"mainVC"];
       
    }
 

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleProductRequestNotification:)
                                                 name:IAPProductRequestNotification
                                               object:[StoreManager sharedInstance]];
    
    

    
    NSURL *plistURL = [[NSBundle mainBundle] URLForResource:@"ProductIds" withExtension:@"plist"];
    NSArray *productIds = [NSArray arrayWithContentsOfURL:plistURL];
    [[StoreManager sharedInstance] fetchProductInformationForIds:productIds];

    [[SKPaymentQueue defaultQueue] addTransactionObserver:[StoreObserver sharedInstance]];

    
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
    
    return YES;
    
}


-(void)handleProductRequestNotification:(NSNotification *)notification
{
    StoreManager *productRequestNotification = (StoreManager*)notification.object;
    IAPProductRequestStatus result = (IAPProductRequestStatus)productRequestNotification.status;
    
    if (result == IAPProductRequestResponse)
    {
        NSMutableArray *productArray =    productRequestNotification.productRequestResponse;
        self.product = (SKProduct *)[productArray firstObject];
        NSLog(@"Dit is het product: %@", self.product);
        NSString *prijs = [[StoreManager sharedInstance]productPrice];

    }
}


- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options;
{
    NSURL *openUrl = url;
    
    if (!openUrl)
    {
        return NO;
    }
    return [self openLink:openUrl];
}

- (BOOL)openLink:(NSURL *)urlLink
{
 
    UITabBarController *view = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"mainVC"];
    view.selectedIndex = 1;
    [[UIApplication sharedApplication].keyWindow.rootViewController  presentViewController:view animated:YES completion:nil];
    
    return true;
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    if (self.launchedURL) {
        [self openLink:self.launchedURL];
        self.launchedURL = nil;
    }
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
