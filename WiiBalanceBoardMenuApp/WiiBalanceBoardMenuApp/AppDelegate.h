//
//  AppDelegate.h
//  WiiBalanceBoardMenuApp
//
//  Created by Matthias Vermeulen on 29/11/16.
//  Copyright © 2016 Matthias Vermeulen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>


@property (readwrite, retain) IBOutlet NSMenu *menu;
@property (readwrite, retain) IBOutlet NSStatusItem *statusItem;

@end

