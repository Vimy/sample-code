//
//  ActionViewController.m
//  Incognito
//
//  Created by Matthias Vermeulen on 12/01/17.
//  Copyright © 2017 Matthias Vermeulen. All rights reserved.
//

#import "ActionViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <WebKit/WebKit.h>
#import "urlSharingFramework.h"
#import "CRToast/CRToast.h"
#import "InfoView.h"
#import "KINWebBrowserViewController.h"

@interface ActionViewController () <WKNavigationDelegate, WKUIDelegate>

@property (weak, nonatomic) IBOutlet UIView *browserView;
@property (nonatomic, strong) NSExtensionContext *extensionContext;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigatieBar;
@property (strong, nonatomic) WKWebView *webView;
@property (nonatomic, strong) NSString *urlForSaving;
@property (nonatomic, strong) NSString *titleForSaving;
@property (nonatomic, strong) UrlShare *urlManager;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UILabel *visitsLabel;
@property  BOOL isAuthorisedToViewWeb;
@property  NSInteger freeVisits;
@property NSUserDefaults *defaults;

@end

@implementation ActionViewController


- (void)beginRequestWithExtensionContext:(NSExtensionContext *)context
{
    self.extensionContext = context;
    
    BOOL found = NO;
        for (NSExtensionItem *item in self.extensionContext.inputItems) {
            for (NSItemProvider *itemProvider in item.attachments) {
                if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypePropertyList])
                {
                    [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypePropertyList options:nil completionHandler:^(NSDictionary *jsDictionary, NSError *error)
                     {
                         [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                             NSDictionary *results = jsDictionary[NSExtensionJavaScriptPreprocessingResultsKey];
                             
                             [self loadWebsite:results[@"URL"]];
                             self.urlForSaving = results[@"URL"];
                         }];
                     }];
                    found = YES;
                }
                break;
            }
            if (found) {
                break;
            }
        }
        
        if (!found)
        {
            NSLog(@"Bummer");
        }

}

- (bool)userEligibleToViewSite
{
    
    if([self.defaults boolForKey:@"hasPayed"])
    {
        return [self.defaults boolForKey:@"hasPayed"];
    }
    else
    {
        return [self.defaults boolForKey:@"hasReachedFreeLimit"];
    }
}

- (void)resetUserSettings
{
    [self.defaults setInteger:0 forKey:@"countOfFreeVisits"];
    [self.defaults setBool:NO forKey:@"hasReachedFreeLimit"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tracker = [GAI sharedInstance].defaultTracker;
    [self.tracker set:kGAIScreenName value:@"extension view"];
    [self.tracker send:[[GAIDictionaryBuilder createScreenView] build]];
 
    
    self.defaults = [[NSUserDefaults alloc]initWithSuiteName:@"group.net.noizystudios.urlGroup"];
    self.isAuthorisedToViewWeb = YES;
    
     if([self.defaults boolForKey:@"hasPayed"])
     {
         self.visitsLabel.text =@"";
     }
    else
    {
        
        if(![self.defaults integerForKey:@"countOfFreeVisits"])
        {
            self.freeVisits = 2;
        }
        NSDate *nowDate = [NSDate date];
        NSDate *savedDate = (NSDate *)[self.defaults objectForKey:@"vorigeDate"];
        
        
        if (!savedDate)
        {
            [self.defaults setObject:nowDate forKey:@"vorigeDate"];
            [self.defaults synchronize];
        }
        
        
        if ([self isSameDayWithDateOne:nowDate dateTwo:savedDate])
        {
            [self checkFreeVisits];
            [self.defaults setObject:nowDate forKey:@"vorigeDate"];
            
        }
        else
        {
            [self.defaults setInteger:2 forKey:@"countOfFreeVisits"];
            [self.defaults setBool:NO forKey:@"hasReachedFreeLimit"];
            [self.defaults setObject:nowDate forKey:@"vorigeDate"];
            [self checkFreeVisits];
            
        }
        
        [self.defaults synchronize];
        
    }
    self.navigatieBar.tintColor = [UIColor whiteColor];
    self.navigatieBar.barTintColor = [UIColor darkGrayColor];
    self.view.backgroundColor = [UIColor darkGrayColor];
    self.view.tintColor = [UIColor darkGrayColor];
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    [self.progressView setTrackTintColor:[UIColor colorWithWhite:1.0f alpha:0.0f]];
    [self.view addSubview:self.progressView];

    NSLayoutConstraint *constraint;
    constraint = [NSLayoutConstraint constraintWithItem:self.progressView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.navigatieBar attribute:NSLayoutAttributeBottom multiplier:1 constant:-0.5];
    [self.view addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.progressView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.navigatieBar  attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    [self.view addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.progressView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.navigatieBar  attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    [self.view addConstraint:constraint];
    
    [self.progressView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
}


- (void)checkFreeVisits
{
    if([self.defaults boolForKey:@"hasReachedFreeLimit"])
    {
        self.isAuthorisedToViewWeb = NO;
        self.freeVisits = 2;
    }
    else
    {
        self.freeVisits = [self.defaults integerForKey:@"countOfFreeVisits"];
        //self.freeVisits =  self.freeVisits + 1;
        NSInteger ii = self.freeVisits;
        self.freeVisits = ii-1;
        
        [self.defaults setInteger:self.freeVisits forKey:@"countOfFreeVisits"];
        [self.defaults synchronize];
        if (self.freeVisits == 0)
        {
            [self.defaults setBool:YES forKey:@"hasReachedFreeLimit"];
            [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"incognito extensie visit"
                                                                       action:@"limit reached"
                                                                        label:@"limit reached"
                                                                        value:@1] build]];
        }
        
    }
    

   
    [self.defaults setInteger:self.freeVisits forKey:@"countOfFreeVisits"];

}

- (void)showRemainingVisitsInfoViewWithText:(NSString *)string
{


    
    InfoView *view = [[NSBundle mainBundle]loadNibNamed:@"InfoWindow" owner:self options:nil].firstObject;
    view.backgroundColor = [UIColor grayColor];
    


    CGRect frame = CGRectMake(0, 0, 320, 60);
    
    frame.origin.y  = [UIScreen mainScreen].bounds.size.height;

    frame.size.width = self.navigatieBar.frame.size.width;
    view.frame = frame;
    view.infoLabel.text = string;
    
    [self.view addSubview:view];
    
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = view.frame;
        frame.origin.y =  [UIScreen mainScreen].bounds.size.height - view.frame.size.height;
        view.frame = frame;
    }];

    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5f
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             CGRect frame = view.frame;
                             frame.origin.y = [UIScreen mainScreen].bounds.size.height;/
                             view.frame = frame;
                         }
                         completion:^(BOOL finished){
                         }
         ];
        
    });
   
    

    
}

-(void)applicationSignificantTimeChange:(UIApplication *)application
{
    //tell your view to shuffle
}


- (BOOL)isSameDayWithDateOne:(NSDate *)dateOne dateTwo:(NSDate *)dateTwo{
    
    NSCalendar *calender = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    
    NSDateComponents *compOne = [calender components:unitFlags fromDate:dateOne];
    NSDateComponents *compTwo = [calender components:unitFlags fromDate:dateTwo];
    
    return ([compOne day] == [compTwo day] && [compOne month] == [compTwo month] && [compOne year] == [compTwo year]);
}

-(void)dateFromUTCTimeStamp:(NSString *)dateString
{
    
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *myDate = [df dateFromString: dateString];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [df setTimeZone:gmt];
    
    [[NSUserDefaults standardUserDefaults] setObject:myDate forKey:@"lastDatePlayed"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)loadWebsite:(NSString *)urlString
{
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"incognito extension"
                                                               action:@"website loading"
                                                                label:@"website loading"
                                                                value:@1] build]];

    
    
    if(self.isAuthorisedToViewWeb)
    {
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc]init];
    [config setWebsiteDataStore:[WKWebsiteDataStore nonPersistentDataStore]];
      //  CGRect viewFrame = self.webView.frame;
        
        CGRect viewFrame = self.browserView.frame;
    viewFrame.size.height = self.view.frame.size.height - self.navigatieBar.frame.size.height;
    
    self.webView = [[WKWebView alloc] initWithFrame:viewFrame configuration:config] ;
    [self.webView addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:NSKeyValueObservingOptionNew context:NULL];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView setUIDelegate:self];
    [self.webView setNavigationDelegate: self];
  //  [self.webView setAutoresizesSubviews:YES];
    [self.webView loadRequest:request];     
    [self.view addSubview:self.webView];
   
    }
    else
    {
         [self.visitsLabel setHidden:true];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Free limit reached" message:@"Get the premium option if you want to view more sites today. Or you can wait until tomorrow." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"Go Premium"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 
                                 NSString *className = [[NSString alloc] initWithData:[NSData dataWithBytes:(unsigned char []){0x55, 0x49, 0x41, 0x70, 0x70, 0x6C, 0x69, 0x63, 0x61, 0x74, 0x69, 0x6F, 0x6E} length:13] encoding:NSASCIIStringEncoding];
                                 if (NSClassFromString(className)) {
                                     id object = [NSClassFromString(className) performSelector:@selector(sharedApplication)];
                                     [object performSelector:@selector(openURL:) withObject:[NSURL URLWithString:@"incogext://blabla" ]];
                                 }
                                 
                                 NSDictionary *result = @{
                                                          //@"statusMessage": @"???"
                                                          };
                                 
                                 [self.extensionContext completeRequestReturningItems:@[result] completionHandler:nil];
                                 
                                 

                                 
                             }];
        UIAlertAction* No = [UIAlertAction
                             actionWithTitle:@"I'll wait"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [self done];
                                 
                             }];
        [alert addAction:ok];
        [alert addAction:No];
        [self presentViewController:alert animated:YES completion:nil];

    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done
{
    NSDictionary *result = @{
                             //@"statusMessage": @"???"
                             };
    
    [self.extensionContext completeRequestReturningItems:@[result] completionHandler:nil];
}

- (IBAction)saveURL
{
    
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"incognito extension"
                                                               action:@"website opslaan"
                                                                label:@"website opslaan"
                                                                value:@1] build]];
    
    self.urlManager = [UrlShare UrlShareManager];
    
    BOOL isDuplicate = NO;
    
    self.titleForSaving = self.webView.title;
    
    NSMutableArray *urlArray = [self.urlManager loadURLS];
    Bookmark *jos= [[Bookmark alloc]init];
    jos.title =  self.titleForSaving; //
 
    jos.urlString = self.urlForSaving;
    

        for (Bookmark *markske in urlArray)
        {
            if ([markske isEqual:jos])
            {
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Duplicate alert" message:@"You already saved this article." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* ok = [UIAlertAction
                                     actionWithTitle:@"OK"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         //   [alert dismissViewControllerAnimated:YES completion:nil];
                                         
                                     }];
                [alert addAction:ok];
                [self presentViewController:alert animated:YES completion:nil];
                
                isDuplicate = YES;
            }
            
           
        }

    if(!isDuplicate)
    {
        [self saveBookmarks];
    }

}

- (void)dealloc {
    
    if ([self isViewLoaded]) {
        [self.webView removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
    }
    
    // if you have set either WKWebView delegate also set these to nil here
    [self.webView setNavigationDelegate:nil];
    [self.webView setUIDelegate:nil];
}


- (void)saveBookmarks
{
    [self.urlManager addURL:self.urlForSaving andTitle:self.titleForSaving];
  

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Saved" message:nil preferredStyle:UIAlertControllerStyleAlert]; // 7
    [self presentViewController:alert animated:YES completion:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    });
}



#pragma mark - Estimated Progress KVO (WKWebView)

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))] && object == self.webView) {
        [self.progressView setAlpha:1.0f];
        BOOL animated = self.webView.estimatedProgress > self.progressView.progress;
        [self.progressView setProgress:self.webView.estimatedProgress animated:animated];
        
        // Once complete, fade out UIProgressView
        if(self.webView.estimatedProgress >= 1.0f) {
            [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.progressView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [self.progressView setProgress:0.0f animated:NO];
                    NSString *string = [NSString stringWithFormat:@"Remaining free visits: %li/2", (long)self.freeVisits];
                if(![self.defaults boolForKey:@"hasPayed"])
                {
                   [self showRemainingVisitsInfoViewWithText:string];
                }
              
            }];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


@end
