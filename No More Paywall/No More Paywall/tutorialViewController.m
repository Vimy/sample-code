//
//  tutorialViewController.m
//  No More Paywall
//
//  Created by Matthias Vermeulen on 19/01/17.
//  Copyright © 2017 Matthias Vermeulen. All rights reserved.
//
#import <Google/Analytics.h>
#import "tutorialViewController.h"
#define RGB(r, g, b) [UIColor colorWithRed:(float)r / 255.0 green:(float)g / 255.0 blue:(float)b / 255.0 alpha:1.0]


@interface tutorialViewController ()

@end

@implementation tutorialViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker set:kGAIScreenName value:@"tutorialView"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects: (id)[RGB(244,190,68) CGColor],(id)[RGB(243,120,64) CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
    

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)continueButtonTapped:(UIButton *)sender
{
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:@"hasLaunchedBefore"])
    {
        [defaults setBool:TRUE forKey:@"hasLaunchedBefore"];
        UIViewController *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"mainVC"];
        [self presentViewController:viewController  animated:YES completion:Nil];

    }
    else
    {
            [self dismissViewControllerAnimated:YES
                                     completion:nil];
    }
      
        
      
    
    

    
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
