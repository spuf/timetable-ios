//
//  GroupsViewController.h
//  Timetable HSE
//
//  Created by Арсений Разин on 20.09.12.
//  Copyright (c) 2012 Арсений Разин. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Api.h"

@interface GroupsViewController : UITableViewController<ApiResponseDelegate>
{
	NSArray *groupsData;
}

@end
