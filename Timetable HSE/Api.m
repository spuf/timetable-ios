//
//  Api.m
//  Timetable HSE
//
//  Created by Арсений Разин on 26.09.12.
//  Copyright (c) 2012 Арсений Разин. All rights reserved.
//

#import "Api.h"

#define API_LINK (@"http://timetable.spuf.ru/api.php?api=3&")

@implementation Api

@synthesize delegate;

- (void)call:(NSString*)params
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", API_LINK, params]];
	NSLog(@"Call: %@", url);
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];

    if(connection) {
        responseData = [[NSMutableData alloc] init];
    } else {
        NSLog(@"init failed");
		[[self delegate] apiDataFailed];
    }
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [responseData appendData:data];
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

	UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Ошибка"
													  message:@"Нет подключения к Интернету"
													 delegate:self
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [message show];
    NSLog(@"connection error");
	[[self delegate] apiDataFailed];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"connection success");
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	NSError *e = nil;
    jsonData = [NSJSONSerialization JSONObjectWithData: responseData options: NSJSONReadingMutableContainers error: &e ];

    if (!jsonData) {
        NSLog(@"Error parsing JSON: %@", e);
		[[self delegate] apiDataFailed];
    } else {
		[[self delegate] apiDataLoaded:jsonData];
	}
}

@end
