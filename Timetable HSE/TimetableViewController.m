//
//  TimetableViewController.m
//  Timetable HSE
//
//  Created by Арсений Разин on 20.09.12.
//  Copyright (c) 2012 Арсений Разин. All rights reserved.
//

#import "TimetableViewController.h"
#import "PairCell.h"

@interface TimetableViewController ()

@end

@implementation TimetableViewController

static UILabel *testLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
	pairsData = [[NSArray alloc] init];
	siteUrl = @"http://timetable.spuf.ru/";
	dataChecksum = @"";
	testLabel = [[UILabel alloc] init];
	timeInterval = 0;

	UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	activityIndicator.frame = CGRectMake(
										 activityIndicator.frame.origin.x,
										 activityIndicator.frame.origin.y,
										 activityIndicator.frame.size.width + 12,
										 activityIndicator.frame.size.height);
	[activityIndicator startAnimating];
	activityButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];

	updateButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(update:)];

	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSDictionary *cache = [prefs dictionaryForKey:@"cache"];
	if (cache != nil) {
		[self updateTable:cache checksum:[cache objectForKey:@"checksum"]];
	}

	if ([UIRefreshControl class]) {
		UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
		[refreshControl addTarget:self action:@selector(update:) forControlEvents:UIControlEventValueChanged];
		self.refreshControl = refreshControl;
	}
}

- (void)viewDidUnload
{
	updateButton = nil;
	activityButton = nil;
	pairsData = nil;
	siteUrl = nil;
	dataChecksum = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger days = pairsData.count;
    return days + 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString *header;
	if (section < pairsData.count) {
		NSDictionary *day = [NSDictionary dictionaryWithDictionary:[pairsData objectAtIndex:section]];
		header = [NSString stringWithFormat:@"%@ (%@)", [day objectForKey:@"dow"], [day objectForKey:@"date"]];
	} else {
		header = @"";
	}
    return header;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows;
    if (section < pairsData.count) {
		NSArray *pairs = [NSArray arrayWithArray:[[pairsData objectAtIndex:section] objectForKey:@"pairs"]];
		rows = pairs.count;
	} else {
		rows = 1;
	}
    return rows;
}

- (NSString *)titleForPair:(NSDictionary *)pair full:(bool)full
{
	
	if (full && [[pair objectForKey:@"with"] length] > 0)
		return [NSString stringWithFormat:@"%@\nВместе с %@", [pair objectForKey:@"title"], [pair objectForKey:@"with"]];
	else
		return [pair objectForKey:@"title"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < pairsData.count) {
		PairCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

		NSArray *pairs = [NSArray arrayWithArray:[[pairsData objectAtIndex:indexPath.section] objectForKey:@"pairs"]];
		NSDictionary *pair = [NSDictionary dictionaryWithDictionary:[pairs objectAtIndex:indexPath.row]];

		cell.numberLabel.text = [NSString stringWithFormat:@"%u", [[pair objectForKey:@"number"] integerValue]];
		cell.timeLabel.text = [pair objectForKey:@"time"];
		if ([cell.titleLabel respondsToSelector:@selector(setAttributedText:)]) {
			NSMutableAttributedString *text = [[NSMutableAttributedString alloc]
											   initWithString:[self titleForPair:pair full:YES]];
			if ([[pair objectForKey:@"style"] rangeOfString:@"underline"].location != NSNotFound) {
				[text setAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
									 [NSNumber numberWithInt:1], NSUnderlineStyleAttributeName,
									 nil]
							  range:NSMakeRange(0,
												[[pair objectForKey:@"title"] length])];
			}
			[text setAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
								 [UIFont systemFontOfSize:12.f], NSFontAttributeName,
								 [UIColor grayColor], NSForegroundColorAttributeName,
								 nil]
						  range:NSMakeRange([[pair objectForKey:@"title"] length],
											[text length] - [[pair objectForKey:@"title"] length])];
			cell.titleLabel.attributedText = text;
		} else {
			cell.titleLabel.text = [self titleForPair:pair full:NO];
		}

		return cell;
    } else {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LinkCell"];
		return cell;
    }
}

#define CELL_CONTENT_MARGIN 4.0f

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *text;
	//NSLog(@"%f", tableView.bounds.size.width);
    if (indexPath.section < pairsData.count) {
        NSArray *pairs = [NSArray arrayWithArray:[[pairsData objectAtIndex:indexPath.section] objectForKey:@"pairs"]];
		NSDictionary *pair = [NSDictionary dictionaryWithDictionary:[pairs objectAtIndex:indexPath.row]];
		text = [self titleForPair:pair full:[testLabel respondsToSelector:@selector(setAttributedText:)]];
    } else {
        text = @"";
	}
	// Get a CGSize for the width and, effectively, unlimited height
    CGSize constraint = CGSizeMake(202.0f * tableView.bounds.size.width / 320 - (CELL_CONTENT_MARGIN * 2), 20000.0f);
    // Get the size of the text given the CGSize we just made as a constraint
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    // Get the height of our measurement, with a minimum of 44 (standard cell size)
    CGFloat height = MAX(size.height, 44.0f);
    // return the height, with a bit of extra padding in
    return height + (CELL_CONTENT_MARGIN * 2);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == pairsData.count && indexPath.row == 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: siteUrl]];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"Hide");
}

- (void)viewDidAppear:(BOOL)animated
{
    [self update:nil];
}

- (IBAction)update:(id)sender {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSInteger groupId = [prefs integerForKey:@"groupId"];
	NSLog(@"groupId = %u", groupId);

	timeInterval = [NSDate timeIntervalSinceReferenceDate];

	if (groupId > 0) {
		self.navigationItem.rightBarButtonItem = activityButton;
		Api *api = [[Api alloc] init];
		api.delegate = self;

		[api call:[NSString stringWithFormat:@"query=latest&group=%u&days=7", groupId]];
	} else {
		[self performSegueWithIdentifier:@"selectGroup" sender:self];
	}
}

- (void)updateTable:(NSDictionary*)data checksum:(NSString*)checksum
{
	dataChecksum = checksum;
	self.title = [data objectForKey:@"group"];
	siteUrl = [data objectForKey:@"link"];
	pairsData = [NSArray arrayWithArray:[data objectForKey:@"timetable"]];
	[self.tableView reloadData];
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, pairsData.count)] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)apiDataLoaded:(NSDictionary*)jsonData
{
	NSString *newChecksum = [jsonData objectForKey:@"checksum"];
	if (![dataChecksum isEqualToString:newChecksum]) {
		[self updateTable:jsonData checksum:newChecksum];
		NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
		[prefs setObject:jsonData forKey:@"cache"];
		[prefs synchronize];
	} else {
		NSLog(@"checksum is same");
	}
	NSTimeInterval delay = 1.0 - ([NSDate timeIntervalSinceReferenceDate] - timeInterval);
	delay = MAX(0.0, MIN(1.0, delay));
	NSLog(@"delay=%f", delay);
	[self performSelector:@selector(updateButtonState) withObject:self afterDelay:delay];
}

- (void)updateButtonState
{
	if ([self respondsToSelector:@selector(refreshControl)]) {
		[self.refreshControl endRefreshing];
	}
	self.navigationItem.rightBarButtonItem = updateButton;
}

- (void)apiDataFailed
{
	NSLog(@"no inet");
	[self updateButtonState];
}

@end
