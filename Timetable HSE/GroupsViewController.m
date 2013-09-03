//
//  GroupsViewController.m
//  Timetable HSE
//
//  Created by Арсений Разин on 20.09.12.
//  Copyright (c) 2012 Арсений Разин. All rights reserved.
//

#import "GroupsViewController.h"

@interface GroupsViewController ()

@end

@implementation GroupsViewController
{
    NSInteger selectedGroupRow;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	groupsData = [[NSArray alloc] init];
    selectedGroupRow = NSNotFound;

	[self update:nil];
}

- (IBAction)update:(id)sender
{
	UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	activityIndicator.frame = CGRectMake(
										 activityIndicator.frame.origin.x,
										 activityIndicator.frame.origin.y,
										 activityIndicator.frame.size.width + 12,
										 activityIndicator.frame.size.height);
	[activityIndicator startAnimating];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];

	Api *api = [[Api alloc] init];
	api.delegate = self;
	[api call:@"query=groups"];
}

- (void)apiDataLoaded:(NSDictionary*)jsonData
{
	groupsData = [NSArray arrayWithArray:[jsonData objectForKey:@"groups"]];
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSInteger groupId = [prefs integerForKey:@"groupId"];
    NSLog(@"groupId = %u", groupId);
	if (groupId > 0) {
		for (NSDictionary *group in groupsData) {
			if ([[group objectForKey:@"id"] integerValue] == groupId) {
				selectedGroupRow = [groupsData indexOfObjectIdenticalTo:group];
			}
		}
		NSLog(@"selectedGroupRow = %u", selectedGroupRow);
	}
	self.navigationItem.rightBarButtonItem = nil;
	[self.tableView reloadData];
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)apiDataFailed
{
	NSLog(@"no inet");
	//self.navigationItem.rightBarButtonItem = nil;
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(update:)];

}

- (void)viewDidUnload
{
	groupsData = nil;
	[super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return groupsData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (indexPath.row == selectedGroupRow)
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	else
		cell.accessoryType = UITableViewCellAccessoryNone;

	cell.textLabel.text = [[groupsData objectAtIndex:indexPath.row] objectForKey:@"name"];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (selectedGroupRow != NSNotFound)
	{
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedGroupRow inSection:0]];
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
    selectedGroupRow = indexPath.row;
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	cell.accessoryType = UITableViewCellAccessoryCheckmark;

	NSLog(@"Select group: %@", [groupsData objectAtIndex:indexPath.row]);
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:[[[groupsData objectAtIndex:indexPath.row] objectForKey:@"id"] integerValue] forKey:@"groupId"];
    [prefs synchronize];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"SelectGroup"]) {
        NSLog(@"prepareForSegue: SelectGroup");
    }
}

@end
