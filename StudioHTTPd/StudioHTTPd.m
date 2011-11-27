//
//  StudioHTTPd.m
//  StudioHTTPd
//
//  Created by Pablo Merino on 12/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "StudioHTTPd.h"
#import "AppDelegate.h"
#import "WebClass.h"

@interface NSString (ParseCategory)
- (NSMutableDictionary *)explodeToDictionaryInnerGlue:(NSString *)innerGlue outterGlue:(NSString *)outterGlue;
@end

@implementation NSString (ParseCategory)

- (NSMutableDictionary *)explodeToDictionaryInnerGlue:(NSString *)innerGlue outterGlue:(NSString *)outterGlue {
    // Explode based on outter glue
    NSArray *firstExplode = [self componentsSeparatedByString:outterGlue];
    NSArray *secondExplode;
    
    // Explode based on inner glue
    NSInteger count = [firstExplode count];
    NSMutableDictionary *returnDictionary = [NSMutableDictionary dictionaryWithCapacity:count];
    for (NSInteger i = 0; i < count; i++) {
        secondExplode = [(NSString *)[firstExplode objectAtIndex:i] componentsSeparatedByString:innerGlue];
        if ([secondExplode count] == 2) {
            [returnDictionary setObject:[secondExplode objectAtIndex:1] forKey:[secondExplode objectAtIndex:0]];
        }
    }
    
    return returnDictionary;
}

@end

@implementation StudioHTTPd
@synthesize requestArray, requestGET, requestURL, requestPath, delegate;
-(void)setDelegate:(id<StudioHTTPdDelegate>)_delegate {
    delegate = _delegate;
}
- (id)initWithPort:(long)_port 
{
    if (_port) {
        port = _port;
    } else {
        port = 40182;
    }

    
    return self;
}

- (void) startServerLocal
{
    NSLog(@"Started StudioHTTPd Server at Port: %lu", port);
    
    listenSocket = [[AsyncSocket alloc] initWithDelegate:self];
	[listenSocket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
    NSError *error = nil;
    [listenSocket acceptOnPort:port error:&error];
    connectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
}

-(void)startServer
{
    [self startServerLocal];
}

- (void)dealloc
{
    [super dealloc];
}


- (NSString*) getApplicationPath 
{
    NSWorkspace *wp = [[NSWorkspace alloc] init];
    NSString *bundleId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString *allApp = [wp absolutePathForAppBundleWithIdentifier:bundleId];
    NSMutableString *appPath = [NSMutableString stringWithString:allApp];
    [wp release];
    return appPath;
}

- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
{
	[connectedSockets addObject:newSocket];
    
    //NSLog(@"new client");
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	//self logInfo:FORMAT(@"Accepted client %@:%hu", host, port)];
	
	//NSString *welcomeMsg = @"<h1>Welcome to the AsyncSocket Echo Server</h1>\r\n";
	//NSData *welcomeData = [welcomeMsg dataUsingEncoding:NSUTF8StringEncoding];
	
	//[sock writeData:welcomeData withTimeout:-1 tag:5];
	[sock readDataToData:[AsyncSocket CRLFData] withTimeout:2 tag:0];
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    //NSLog(@"daat wrote");
    [sock disconnect];
    
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length] - 2)];
	NSString *msg = [[[NSString alloc] initWithData:strData encoding:NSUTF8StringEncoding] autorelease];
    NSArray *request = [msg componentsSeparatedByString:@" "];
    NSLog(@"%@",msg);
    [delegate writeToLog:[NSString stringWithFormat:@"%@:%hu - %@", [sock connectedHost], [sock connectedPort], msg]];
    NSString *responseCode = @"404 Not Found";
    NSString *contententType = @"text/html";
    NSMutableString *responseBody = [NSMutableString stringWithFormat:@"<h1>404</h1>"];
    BOOL processingURL = FALSE; 
    NSString *routespliststring = [[NSBundle mainBundle] pathForResource:@"routes" ofType:@"plist"];    

    NSDictionary *routes = [[NSDictionary alloc] initWithContentsOfFile:routespliststring];
    
    
    if([[request objectAtIndex:0] isEqualToString:@"GET"]) {
        self.requestArray = [[request objectAtIndex:1] componentsSeparatedByString:@"?"];
        self.requestPath = [self.requestArray objectAtIndex:0];
        self.requestURL = [[NSURL alloc] initWithString:[request objectAtIndex:1]];
        self.requestGET = [[self.requestURL query] explodeToDictionaryInnerGlue:@"=" outterGlue:@"&"];
        NSLog(@"%@",self.requestGET);
    }
    
    for (NSString* key in routes) {
        if([requestPath isEqualToString:key]) {
            SEL selectorObject = NSSelectorFromString([[NSString alloc] initWithFormat:@"%@:",[routes objectForKey:key]]);
            responseCode = @"200 OK";
            processingURL = TRUE;
            responseBody = [NSMutableString stringWithFormat:@"%@",[WebClass performSelector:selectorObject withObject:self.requestGET]];
        }
    }
    
    if(processingURL == FALSE) {
        
        NSString *filePath = [[NSString alloc] initWithFormat:@"%@/Contents/Resources/public%@",[self getApplicationPath], [request objectAtIndex:1]];
        
        if([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            contententType = @"image/png";
            responseCode = @"200 OK";
            //   responseBody = [[NSString alloc] initWithData:[[NSFileManager defaultManager] contentsAtPath:filePath] encoding:NSASCIIStringEncoding];
            
            NSData *content = [[NSData alloc] initWithContentsOfFile:filePath ];            
            responseBody = [[NSMutableString alloc] initWithData:content encoding:NSASCIIStringEncoding];
            
            
        }
    }
    
    for (NSString *key in requestGET) {
        
        [responseBody replaceOccurrencesOfString:[NSString stringWithFormat:@"##GET['%@']##", key] withString:[requestGET objectForKey:key] options:0 range:NSMakeRange(0, [responseBody length])];
        
    }
    
    NSString *stringResponseBody = [NSString stringWithFormat:@"%@",responseBody];
    
    data = [[NSString stringWithFormat:@"HTTP/1.1 %@\nContent-Type: %@\n\n\n %@", responseCode, contententType, stringResponseBody] dataUsingEncoding:NSUTF8StringEncoding];
    
    
	[sock writeData:data withTimeout:-1 tag:1];
    //[sock disconnect];
    
}
- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
	NSLog(@"Client Disconnected: %@:%hu", [sock connectedHost], [sock connectedPort]);
    
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
	[connectedSockets removeObject:sock];
    
}

@end
