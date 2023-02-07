//
//  AppDelegate.h
//  No More Paywall
//
//  Created by Matthias Vermeulen on 28/11/16.
//  Copyright © 2016 Matthias Vermeulen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoreObserver.h"
#import <Google/Analytics.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SKProduct *product;


@end

