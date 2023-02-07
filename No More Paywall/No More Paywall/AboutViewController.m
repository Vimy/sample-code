//
//  AboutViewController.m
//  No More Paywall
//
//  Created by Matthias Vermeulen on 19/01/17.
//  Copyright © 2017 Matthias Vermeulen. All rights reserved.
//

#define RGB(r, g, b) [UIColor colorWithRed:(float)r / 255.0 green:(float)g / 255.0 blue:(float)b / 255.0 alpha:1.0]


#import "AboutViewController.h"
#import "VTAcknowledgementsViewController.h"
#import "VTAcknowledgement.h"
#import "tutorialViewController.h"
#import "KINWebBrowserViewController.h"
#import <StoreKit/StoreKit.h>
#import "StoreObserver.h"
#import "StoreManager.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import <Google/Analytics.h>


@interface AboutViewController () <KINWebBrowserDelegate, SKStoreProductViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableViewCell *tutorialCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *creditsCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *supportCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *librariesCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *websiteCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *appstoreCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *inappPurchaseCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *restorePurchaseCell;
@property BOOL restoreWasCalled;
@property (strong, nonatomic) UIActivityIndicatorView* indicator;
@property (strong, nonatomic) SKProduct *product;
@property (strong, nonatomic ) NSString *prijsString;
@property (strong, nonatomic) NSArray *productIds;
@property (strong, nonatomic) id<GAITracker> tracker;


// Indicate whether a download is in progress
@property (nonatomic)BOOL hasDownloadContent;
@end

@implementation AboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.separatorColor = RGB(243, 150, 66);
    self.tableView.cellLayoutMarginsFollowReadableWidth = NO;

    self.tracker = [GAI sharedInstance].defaultTracker;
    [self.tracker set:kGAIScreenName value:@"aboutView"];
    [self.tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    
    self.hasDownloadContent = NO;
    self.restoreWasCalled = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleProductRequestNotification:)
                                                 name:IAPProductRequestNotification
                                               object:[StoreManager sharedInstance]];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handlePurchasesNotification:)
                                                 name:IAPPurchaseNotification
                                               object:[StoreObserver sharedInstance]];
    
    
    if ([(AppDelegate *)[UIApplication sharedApplication].delegate product])
    {
        self.product = [(AppDelegate *)[UIApplication sharedApplication].delegate product];
        NSString *prijs = [[StoreManager sharedInstance]productPrice];
        //  NSLog(@"Tekst: %@", self.priceLabel.text);
        
        self.prijsString = [NSString stringWithFormat:@"For %@ you can unlock unlimited incognito visits.", prijs];
        NSLog(@"prijsstring: %@", self.prijsString);
    }
    else
    {
        NSURL *plistURL = [[NSBundle mainBundle] URLForResource:@"ProductIds" withExtension:@"plist"];
        self.productIds = [NSArray arrayWithContentsOfURL:plistURL];
        [[StoreManager sharedInstance] fetchProductInformationForIds:self.productIds];
    }
     
     
     
    

 

    
    
//IAPPurchaseFailedNotification
    
    
    
//http://stackoverflow.com/questions/19556336/how-do-you-add-an-in-app-purchase-to-an-ios-application
    
    self.tableView.delegate = self;
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Display message

-(void)alertWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark in-app purchase
-(void)removeLimitPurchase
{
    if([SKPaymentQueue canMakePayments])
    {
        // Load the product identifiers fron ProductIds.plist
       
        if(!self.product)
        {
            [self alertWithTitle:@"Warning" message:@"Couldn't complete purchase. Please try again later"];
        }
        else
        {
            [[StoreObserver sharedInstance] buy:self.product];
        }
      
        
        
    }
    else
    {
        // Warn the user that they are not allowed to make purchases.
        [self alertWithTitle:@"Warning" message:@"Purchases are disabled on this device."];
    }

}

//http://stackoverflow.com/questions/28905970/price-of-in-app-purchases-shown-on-screenwith-currency

#pragma mark Handle purchase request notification

// Update the UI according to the purchase request notification result
-(void)handlePurchasesNotification:(NSNotification *)notification
{
    StoreObserver *purchasesNotification = (StoreObserver *)notification.object;
    IAPPurchaseNotificationStatus status = (IAPPurchaseNotificationStatus)purchasesNotification.status;
    NSString *message = [NSString stringWithFormat:@"Couldn't complete purchase. Try again later. Error: %@", purchasesNotification.message];
    
    switch (status)
    {
        case IAPPurchaseFailed:
            
            [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"in-purchase"
                                                                       action:@"purchase failed"
                                                                        label:@"purchase failed"
                                                                        value:@1] build]];
            [self alertWithTitle:@"Purchase Status" message:message];
            
            [SVProgressHUD dismiss];
         
            break;
            // Switch to the iOSPurchasesList view controller when receiving a successful restore notification
        case IAPRestoredSucceeded:
        {
           // self.segmentedControl.selectedSegmentIndex = 1;
            [SVProgressHUD dismiss];
            self.restoreWasCalled = YES;
            [self removeLimit];
            [self alertWithTitle:@"Restore Complete" message:@"You now have unlimited incognito visits in Safari!"];
            [self.tableView reloadData];
            // [self dismissViewControllerAnimated:true completion:nil];
           // [self cycleFromViewController:self.currentViewController toViewController:self.purchasesList];
          //  [self.purchasesList reloadUIWithData:[self dataSourceForPurchasesUI]];
            break;
        }
        case IAPPurchaseSucceeded:
        {
            [SVProgressHUD dismiss];
            [self removeLimit];
            [self alertWithTitle:@"Purchase Complete" message:@"You now have unlimited incognito visits in Safari!"];
            [self.tableView reloadData];
        }
            break;
        case IAPRestoredFailed:
            [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"in-purchase"
                                                                       action:@"restore failed"
                                                                        label:@"restore failed"
                                                                        value:@1] build]];
            [self alertWithTitle:@"Purchase Status" message:purchasesNotification.message];
            // [self.indicator
            break;
            // Notify the user that downloading is about to start when receiving a download started notification
        case IAPDownloadStarted:
        {
            NSLog(@"Download started");
            self.hasDownloadContent = YES;
           // [self.view addSubview:self.statusMessage];
        }
            break;
            // Display a status message showing the download progress
        case IAPDownloadInProgress:
        {
            NSLog(@"Download in progress");
            self.hasDownloadContent = YES;
//
        }
            break;
            // Downloading is done, remove the status message
        case IAPDownloadSucceeded:
        {
            NSLog(@"Download succeeded");
             [self dismissViewControllerAnimated:true completion:nil];
            self.hasDownloadContent = NO;
 
            
        }
            break;
        default:
            break;
    }
}

#pragma mark Handle product request notification

// Update the UI according to the product request notification result
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

        
        self.prijsString = [NSString stringWithFormat:@"For %@ you can unlock unlimited incognito visits in Safari.", prijs];
        

    }
}


-(void)restoreLimitsPurchase
{
      [[StoreObserver sharedInstance] restore];
}

- (void)dealloc
{
    // Unregister for StoreManager's notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IAPProductRequestNotification
                                                  object:[StoreManager sharedInstance]];
    
    // Unregister for StoreObserver's notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IAPPurchaseNotification
                                                  object:[StoreObserver sharedInstance]];
}


- (void)removeLimit
{
     NSUserDefaults *defaults = [[NSUserDefaults alloc]initWithSuiteName:@"group.net.noizystudios.urlGroup"];
    
    
    [defaults setBool:true forKey:@"hasPayed"];
    [defaults synchronize];
    
}

#pragma mark tableview

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *tappedCell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (tappedCell == self.tutorialCell)
    {
        
            tutorialViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"onboardingVC"];
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:vc animated:YES completion:Nil];

    }
    else if (tappedCell == self.inappPurchaseCell)
    {
        [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"in-purchase"
                                                             action:@"purchase button pressed"
                                                              label:@"purchase"
                                                              value:@1] build]];
        
        
        if ([[StoreObserver sharedInstance] hasPurchasedProducts])
        {
            [self alertWithTitle:@"Alert" message:@"You already purchased this item."];
            [self restoreLimitsPurchase];
            

        }
        else
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Unlimited incognito visits"
                                                                           message:self.prijsString                                                               preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *buyAction = [UIAlertAction actionWithTitle:@"Buy"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  [SVProgressHUD showWithStatus:@"Please wait..."];
                                                                  [self removeLimitPurchase];
                                                                  
                                                              }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     [SVProgressHUD dismiss];
                                                                     
                                                                     
                                                                 }];
            
            
            [alert addAction:buyAction];
            [alert addAction:cancelAction];
          
            [self presentViewController:alert animated:YES completion:nil];

         
            
        }
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    }
    else if (tappedCell == self.restorePurchaseCell)
    {
        [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"in-purchase"
                                                                   action:@"restore button pressed"
                                                                    label:@"restore"
                                                                    value:@1] build]];
        [self restoreLimitsPurchase];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else if (tappedCell == self.librariesCell)
    {
        [self showLibrariesViewController];
    }
   
    else if (tappedCell == self.supportCell)
    {
        [self showMailViewController];
    }
    else if (tappedCell == self.websiteCell)
    {
        [self showWebsiteViewController];
    }
    else if (tappedCell == self.appstoreCell)
    {
        NSString* cAppleID;
        // must be defined somewhere...
        
        cAppleID = @"1195867998";
        
        NSString * theUrl = [NSString  stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software",cAppleID];
        if ([[UIDevice currentDevice].systemVersion integerValue] > 6) theUrl = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@",cAppleID];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:theUrl]];
        
        if ([SKStoreProductViewController class] != nil) {
            SKStoreProductViewController* skpvc = [SKStoreProductViewController new];
            skpvc.delegate = self;
            NSDictionary* dict = [NSDictionary dictionaryWithObject: cAppleID forKey: SKStoreProductParameterITunesItemIdentifier];
            [skpvc loadProductWithParameters: dict completionBlock: nil];
            [self  presentViewController: skpvc animated: YES completion: nil];
        }
        else {

            [[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1195867998&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software"]];
        }
    }
    
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [viewController dismissViewControllerAnimated: YES completion: nil];
}

- (void)showLibrariesViewController
{
    
    VTAcknowledgementsViewController *viewController;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Pods-No More Paywall-acknowledgements" ofType:@"plist"];
    viewController = [[VTAcknowledgementsViewController alloc] initWithPath:path];
    viewController.headerText = NSLocalizedString(@"We love open source software.", nil); // optional

   [self.navigationController pushViewController:viewController animated:YES];

    
}

- (void)showWebsiteViewController
{
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc]init];
    [config setWebsiteDataStore:[WKWebsiteDataStore defaultDataStore]];
    KINWebBrowserViewController *webBrowser = [KINWebBrowserViewController webBrowserWithConfiguration:config];
    webBrowser.hidesBottomBarWhenPushed = YES;
    [webBrowser setTintColor:RGB(243, 150, 66) ];
    [self.navigationController pushViewController:webBrowser animated:YES];
    [webBrowser loadURLString:@"http://www.noizystudios.net"];
}

- (void)showMailViewController
{
    
    
    
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setSubject:@"Incognito Reader 1.1.2"];
        UIDevice *device = [UIDevice currentDevice];
        NSString *emailBody = [NSString stringWithFormat:@"Description of the problem:\n\n\n\n\n System software: %@ %@ %@", [device model], [device systemName], [device systemVersion]];
        [mail setMessageBody:emailBody isHTML:NO];
        [mail setToRecipients:@[@"matthiasv@noizystudios.net"]];
        
        [self presentViewController:mail animated:YES completion:NULL];
    }
    else
    {
        NSLog(@"This device cannot send email");
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultSent:
            NSLog(@"You sent the email.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"You saved a draft of this email");
            break;
        case MFMailComposeResultCancelled:
            NSLog(@"You cancelled sending this email.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed:  An error occurred when trying to compose this email");
            break;
        default:
            NSLog(@"An error occurred when trying to compose this email");
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
