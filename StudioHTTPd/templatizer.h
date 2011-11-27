//
//  templatizer.h
//  StudioHTTPd
//
//  Created by Hunter Dolan on 11/12/11.
//  Copyright (c) 2011 Studio 182. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface templatizer : NSObject

+(NSString *)templatize:(NSString *)templateName variables:(NSMutableDictionary *)variables;

+(NSString *)templatize:(NSString *)templateName;

@end
