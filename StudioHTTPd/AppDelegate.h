//
//  AppDelegate.h
//  StudioHTTPd
//
//  Created by Pablo Merino on 12/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "StudioHTTPd.h"
@interface AppDelegate : NSObject <NSApplicationDelegate, StudioHTTPdDelegate> {
    IBOutlet NSWindow *window;
    IBOutlet NSTextView *logView;

}
@property(nonatomic, retain) IBOutlet NSWindow *window;
-(IBAction)killServer:(id)sender;
@end
