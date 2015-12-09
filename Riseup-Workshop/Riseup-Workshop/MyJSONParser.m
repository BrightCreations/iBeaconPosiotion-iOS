//
//  MyJSONParser.m
//  SmartLocator
//
//  Created by Ehab Amer on 10/30/11.
//  Copyright (c) 2015 Bright Creations. All rights reserved.
//

#import "MyJSONParser.h"
#define CachePolicy NSURLRequestReloadIgnoringCacheData

@implementation MyJSONParser


+(void)objectWithRequest:(NSMutableURLRequest *)rqust responseDelegate:(id)delegate responseSelector:(SEL)selector
{
	[NSURLConnection sendAsynchronousRequest:rqust queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
		
		NSError *parseError = nil;
		
		if (data == nil) {
			[delegate performSelectorOnMainThread:selector withObject:nil waitUntilDone:NO];
			return ;
		}
		
		NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		
		dataString = [dataString stringByReplacingOccurrencesOfString:@":null" withString:@":\"\""];
		
		data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
		
		id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
		
		if (json) {
			
			[delegate performSelectorOnMainThread:selector withObject:json waitUntilDone:NO];
		}else
			{
			
			[delegate performSelectorOnMainThread:selector withObject:nil waitUntilDone:NO];
			}
	}];
}

@end
