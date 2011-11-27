//
//  StudioHTTPd.h
//  StudioHTTPd
//
//  Created by Pablo Merino on 12/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AsyncSocket.h"
@protocol StudioHTTPdDelegate<NSObject>
-(void)writeToLog:(NSString*)data;
@end
@interface StudioHTTPd : NSObject <AsyncSocketDelegate> {

    AsyncSocket *listenSocket;
	NSMutableArray *connectedSockets;
    NSString *requestPath;
    NSArray *requestArray;
    NSURL *requestURL;
    NSMutableDictionary *requestGET;
    id<StudioHTTPdDelegate> delegate;
    long port;
}
@property(nonatomic, retain) id<StudioHTTPdDelegate> delegate;
@property(nonatomic, retain) NSString *requestPath;
@property(nonatomic, retain) NSArray *requestArray;
@property(nonatomic, retain) NSURL *requestURL;
@property(nonatomic, retain) NSMutableDictionary *requestGET;
- (void)setDelegate:(id<StudioHTTPdDelegate>)_delegate;
- (id)initWithPort:(long)_port;
- (void) startServerLocal;
-(void)startServer;
@end