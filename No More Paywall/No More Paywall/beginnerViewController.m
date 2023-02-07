//
//  beginnerViewController.m
//  No More Paywall
//
//  Created by Matthias Vermeulen on 22/01/17.
//  Copyright © 2017 Matthias Vermeulen. All rights reserved.
//

#import "beginnerViewController.h"
#import "tutorialViewController.h"
#import "AboutViewController.h"

@interface beginnerViewController ()

@end

@implementation beginnerViewController

{
    NSArray *myViewControllers;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.delegate = self;
    self.dataSource = self;
    
    UIViewController *p1 = [self.storyboard
                            instantiateViewControllerWithIdentifier:@"welcomeVC"];
    UIViewController *p2 = [self.storyboard
                            instantiateViewControllerWithIdentifier:@"tutorialVC"];
    
    
    myViewControllers = @[p1,p2];
    
    [self setViewControllers:@[p1]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO completion:nil];
    
    NSLog(@"loaded!");
}

-(UIViewController *)viewControllerAtIndex:(NSUInteger)index
{
    return myViewControllers[index];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController
     viewControllerBeforeViewController:(UIViewController *)viewController
{
    if([viewController isKindOfClass:[tutorialViewController class]])
    {
        return [self.storyboard
                instantiateViewControllerWithIdentifier:@"welcomeVC"];;;;;;;;;;;
    }
    else
    {
        return nil;

    }
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerAfterViewController:(UIViewController *)viewController
{
    if([viewController isKindOfClass:[tutorialViewController class]])
    {
        return nil;
    }
    else
    {
        
        NSUInteger currentIndex2 = [myViewControllers indexOfObject:viewController];
        
        ++currentIndex2;
        currentIndex2 = currentIndex2 % (myViewControllers.count);
        return [myViewControllers objectAtIndex:currentIndex2];
    }
    
}

-(NSInteger)presentationCountForPageViewController:
(UIPageViewController *)pageViewController
{
    return myViewControllers.count;
}

-(NSInteger)presentationIndexForPageViewController:
(UIPageViewController *)pageViewController
{
    return 0;
}


@end
