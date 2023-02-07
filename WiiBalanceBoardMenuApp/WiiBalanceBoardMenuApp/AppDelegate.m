//
//  AppDelegate.m
//  WiiBalanceBoardMenuApp
//
//  Created by Matthias Vermeulen on 29/11/16.
//  Copyright © 2016 Matthias Vermeulen. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)awakeFromNib
{
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    

    self.menu = [[NSMenu alloc] init];
    [self.menu addItemWithTitle:@"Connect" action:@selector(updateStatusItemMenu) keyEquivalent:@""];
    [self.menu addItem:[NSMenuItem separatorItem]];
    [self.menu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@""];
    
    NSImage *menuIcon = [NSImage imageNamed:@"Menu Icon"];
    NSImage *highlightIcon = [NSImage imageNamed:@"Menu Icon"];
    [highlightIcon setTemplate:YES];
    
    [[self statusItem] setImage:menuIcon];
    [[self statusItem] setAlternateImage:highlightIcon];
    [[self statusItem] setMenu:[self menu]];
    [[self statusItem] setHighlightMode:YES];
    

}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}


- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    // Insert code here to tear down your application
}

- (void)updateStatusItemMenu
{
    
    NSStoryboard *storyBoard = [NSStoryboard storyboardWithName:@"Main" bundle:nil]; // get a reference to the storyboard
    NSWindowController *myController = [storyBoard instantiateControllerWithIdentifier:@"MainView"]; // instantiate your window controller
    [myController showWindow:self];
    
    
    
    NSMenu *menu = [[NSMenu alloc] init];
    [menu addItemWithTitle:@"Open Feedbin" action:@selector(openFeedbin:) keyEquivalent:@""];
    
    
        [menu addItemWithTitle:@"Refresh" action:@selector(getUnreadEntries:) keyEquivalent:@""];
        [menu addItemWithTitle:@"Log Out" action:@selector(logOut:) keyEquivalent:@""];
        
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@""];
    
    self.statusItem.menu = menu;
}


@end
