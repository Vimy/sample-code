//
//  ViewController.m
//  WiiBalanceBoardMenuApp
//
//  Created by Matthias Vermeulen on 29/11/16.
//  Copyright © 2016 Matthias Vermeulen. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
{
    __weak IBOutlet NSTextField *balanceBoardStatusLabel;
    SocketIOClient* socket;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    balanceBoardStatusLabel.stringValue = @"Disconnected";
    //[self startWebSocketConnection:nil];
    [spinner setHidden:YES];
    [webserverSpinner setHidden:YES];
    webserverStatusLabel.stringValue = @"Disconnected";
    connectionStatusImage.image = [NSImage imageNamed:@"red"];
    webserverConnectionStatusImage.image = [NSImage imageNamed:@"red"];
  //  [self doDiscovery:nil];
}

- (IBAction)startWebSocketConnection:(id)sender
{
    webserverStatusLabel.stringValue = @"Connecting to server..";

    [webserverSpinner setHidden:NO];
    [webserverSpinner startAnimation:self];
    NSURL* url = [[NSURL alloc] initWithString:@"http://localhost:3000"];
    socket = [[SocketIOClient alloc] initWithSocketURL:url config:@{@"log": @NO, @"forcePolling": @YES}];
    
    
    
    [socket on:@"connection" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"socket connected");
        [webserverSpinner setHidden:YES];
        webserverConnectionStatusImage.image = [NSImage imageNamed:@"green"];
        webserverStatusLabel.stringValue = @"Connected to server";
        
    }];
   // [socket connect];
    [socket connectWithTimeoutAfter:3 withHandler:^{
        NSLog(@"Connection failed!");
        webserverStatusLabel.stringValue = @"Connection failed";
        [webserverSpinner stopAnimation:self];
        [webserverSpinner setHidden:YES];
    }];

}

- (void)setRepresentedObject:(id)representedObject
{
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)expansionPortChanged:(NSNotification *)nc{
    
    WiiRemote* tmpWii = (WiiRemote*)[nc object];
    
    // Check that the Wiimote reporting is the one we're connected to.
    if (![[tmpWii address] isEqualToString:[balanceBoard address]]){
        return;
    }
    
    if ([balanceBoard isExpansionPortAttached]){
        [balanceBoard setExpansionPortEnabled:YES];
    }	
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    [balanceBoard closeConnection];
}

#pragma mark BalanceBoard connection

- (IBAction)doDiscovery:(id)sender
{
    
    NSLog(@"Zoektocht naar balance board gestart");
    if(!discovery) {
        discovery = [[WiiRemoteDiscovery alloc] init];
        [discovery setDelegate:self];
        [discovery start];
        balanceBoardStatusLabel.stringValue = @"Searching...";
        connectionStatusImage.image = [NSImage imageNamed:@"red"];
        [spinner setHidden:NO];
        [spinner startAnimation:self];

    }
    else
    {
        [discovery stop];
        discovery = nil;
        
        if(balanceBoard) {
            [balanceBoard closeConnection];
            balanceBoard = nil;
        }
        balanceBoardStatusLabel.stringValue = @"Disconnected";
        
        [spinner stopAnimation:self];
        [spinner setHidden:YES];

    }
}



#pragma mark web app communication

- (void)sendValuesToServer:(NSDictionary *)valueDic
{
    [socket emit:@"chat-message" with:@[valueDic]];
    NSLog(@"Values sent");
}


#pragma mark WiiRemoteFramework delegate

- (void) buttonChanged:(WiiButtonType) type isPressed:(BOOL) isPressed
{
    
}

- (void) wiiRemoteDisconnected:(IOBluetoothDevice*) device
{
    [device closeConnection];
    balanceBoardStatusLabel.stringValue = @"Disconnected";
    connectionStatusImage.image = [NSImage imageNamed:@"red"];


}

- (void) willStartWiimoteConnections
{
    
}

- (void) WiiRemoteDiscovered:(WiiRemote*)wiimote
{
    balanceBoard = wiimote;
    [balanceBoard setDelegate:self];
    [spinner setHidden:YES];
    [spinner stopAnimation:self];
    balanceBoardStatusLabel.stringValue = @"Connected";
    connectionStatusImage.image = [NSImage imageNamed:@"green"];

}

- (void) WiiRemoteDiscoveryError:(int)code
{
    NSLog(@"Couldn't connect. Error: %u", code);
    [discovery stop];
    sleep(1);
    [discovery start];
    
}

- (void) balanceBeamKilogramsChangedTopRight:(float)topRight
                                 bottomRight:(float)bottomRight
                                     topLeft:(float)topLeft
                                  bottomLeft:(float)bottomLeft
{
    
    
    bottomLeftLabel.stringValue = [[NSNumber numberWithFloat:bottomLeft]stringValue];
    bottomRightLabel.stringValue = [[NSNumber numberWithFloat:bottomRight]stringValue];
    topLeftLabel.stringValue = [[NSNumber numberWithFloat:topLeft]stringValue];
    topRightLabel.stringValue = [[NSNumber numberWithFloat:topRight]stringValue];
    
    NSLog(@"Nummertje: %f", topRight);
    
    
   NSDictionary *dataDic = @{@"topright":[NSNumber numberWithFloat:topRight],@"bottomRight":[NSNumber numberWithFloat:bottomRight],@"topLeft":[NSNumber numberWithFloat:topLeft],@"bottomLeft":[NSNumber numberWithFloat:bottomLeft]};
    
    [self sendValuesToServer:dataDic];
    
 

}



@end
