//
//  templatizer.m
//  StudioHTTPd
//
//  Created by Hunter Dolan on 11/12/11.
//  Copyright (c) 2011 Studio 182. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "templatizer.h"

@implementation templatizer

+(NSString *)templatize:(NSString *)templateName variables:(NSMutableDictionary *)variables
{
    NSString *templatePath = [[NSBundle mainBundle] pathForResource:templateName ofType:@"html" inDirectory:@"templates"];    
    
    NSMutableString *template = [NSMutableString stringWithContentsOfFile:templatePath encoding:NSUTF8StringEncoding error:NULL];
    
    if (variables != NULL) {
        for(NSString *key in variables) {
            [template replaceOccurrencesOfString:[NSString stringWithFormat:@"##@['%@']##", key] withString:[variables objectForKey:key] options:0 range:NSMakeRange(0, [template length])];
        }
    }
    
    return template;
}

+(NSString *)templatize:(NSString *)templateName
{
    return [self templatize:templateName variables:NULL];
}


@end
