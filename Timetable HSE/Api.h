//
//  Api.h
//  Timetable HSE
//
//  Created by Арсений Разин on 26.09.12.
//  Copyright (c) 2012 Арсений Разин. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ApiResponseDelegate <NSObject>

- (void)apiDataLoaded:(NSDictionary*)jsonData;
- (void)apiDataFailed;

@end

@interface Api : NSObject<NSURLConnectionDelegate>
{
	NSDictionary *jsonData;
	NSMutableData *responseData;
}

@property (nonatomic, assign) id <ApiResponseDelegate> delegate;

- (void)call:(NSString*)params;

@end
