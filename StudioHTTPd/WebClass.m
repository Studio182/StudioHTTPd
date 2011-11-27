//
//  WebClass.m
//  StudioHTTPd
//
//  Created by Hunter Dolan on 11/12/11.
//  Copyright (c) 2011 Studio 182. All rights reserved.
//

#import "WebClass.h"
#import "templatizer.h"

@implementation WebClass

+(id)lul:(NSDictionary*)args
{
    //Initilize Variable Array
    
    NSMutableDictionary *variables = [[NSMutableDictionary alloc] initWithDictionary:args];
    
    // Begin Coding
    
    
    //[variables setObject:@"Hunter" forKey:@"name"];
   
    
    // End Coding
    
    // Return Templatized
    
    return [templatizer templatize:@"lul" variables:variables];
}
+(id)helloworld:(NSDictionary*)args
{
    //Initilize Variable Array
    
    NSMutableDictionary *variables = [[NSMutableDictionary alloc] initWithDictionary:args];
    
    // Begin Coding
    
    
    //[variables setObject:@"Hunter" forKey:@"name"];
    
    
    // End Coding
    
    // Return Templatized
    
    return [templatizer templatize:@"helloworld" variables:variables];
}


@end
