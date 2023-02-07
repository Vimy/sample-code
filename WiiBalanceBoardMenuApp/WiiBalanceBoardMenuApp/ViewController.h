//
//  ViewController.h
//  WiiBalanceBoardMenuApp
//
//  Created by Matthias Vermeulen on 29/11/16.
//  Copyright © 2016 Matthias Vermeulen. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WiiRemote.h"
#import "WiiRemoteDiscovery.h"

@import SocketIO;

@interface ViewController : NSViewController <WiiRemoteDelegate, WiiRemoteDiscoveryDelegate>
{
    WiiRemote *balanceBoard;
    WiiRemoteDiscovery *discovery;
    
    __weak IBOutlet NSImageView *webserverConnectionStatusImage;
    __weak IBOutlet NSProgressIndicator *spinner;
    __weak IBOutlet NSTextField *bottomRightLabel;
    __weak IBOutlet NSTextField *bottomLeftLabel;
    __weak IBOutlet NSTextField *topRightLabel;
    __weak IBOutlet NSTextField *topLeftLabel;
    __weak IBOutlet NSImageView *connectionStatusImage;
    __weak IBOutlet NSTextField *webserverStatusLabel;
    __weak IBOutlet NSProgressIndicator *webserverSpinner;
}


@end

