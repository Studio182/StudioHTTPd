#include "AppDelegate.h"
#include "StudioHTTPd.h"


@implementation AppDelegate
@synthesize window;
-(void)applicationDidFinishLaunching:(NSNotification *)notification
{    
    StudioHTTPd *httpd = [[StudioHTTPd alloc] initWithPort:40182];
    [httpd setDelegate:self];
    [httpd startServer];

}
-(IBAction)killServer:(id)sender {
    exit(0);
}
-(void)writeToLog:(NSString*)data {
    NSLog(@"%@", data);
    NSAttributedString *stringToAppend = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", data]];
    [[logView textStorage] appendAttributedString:stringToAppend];
    [logView setFont:[NSFont fontWithName:@"Monaco" size:12]];
    
}
@end
