//
//  MyJSONParser.h
//
//  Created by Ehab Amer on 10/30/11.
//  Copyright (c) 2015 Bright Creations. All rights reserved.
//

#import <Foundation/Foundation.h>

//This is a helper class to simplify loading JSON data from URLs or from URLRequests

@interface MyJSONParser : NSObject
{
    
}
+(void)objectWithRequest:(NSMutableURLRequest *)rqust responseDelegate:(id)delegate responseSelector:(SEL)selector;


@end
