//
//  EPAppController.m
//  Degrees of Tweetdom
//
//  Created by Simone Manganelli on 2008-08-22.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "EPAppController.h"
#import "EPBidirectionalCheckerController.h"
#import "EPTwittererChainFinderController.h"
#import "EPFriendRecommenderController.h"
#import "EPTwittererMapperController.h"


@implementation EPAppController

- (id)init;
{
	if (self = [super init]) {
		arrayOfOperationQueues = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void)dealloc;
{
	[arrayOfOperationQueues release];
	
	[super dealloc];
}

- (void)awakeFromNib;
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(operationQueueCreatedNotification:)
												 name:@"operationQueueCreated"
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(operationQueueDeletedNotification:)
												 name:@"operationQueueDeleted"
											   object:nil];
	[NSTimer scheduledTimerWithTimeInterval:1.0
									 target:self
								   selector:@selector(updateActivityWindowStats)
								   userInfo:nil
									repeats:YES];
}



// I decided to have multiple operation queues throughout the application because
// it made it easier in terms of design if I wanted to have a single activity
// window that was able to give stats on all operations (either I would've had to
// have objects be initialized with an appController pointer, or I would've had to
// post notifications for every single operation, which would have been prohibitively
// expensive)

// upsides: simpler design, no. of NSOperations can be separated out by specific
// task that's being performed; downsides: costlier to count all NSOperations across
// all queues, harder to control resources the app uses;

- (void)operationQueueCreatedNotification:(NSNotification *)notification;
{
	[arrayOfOperationQueues addObject:[notification object]];
}

- (void)operationQueueDeletedNotification:(NSNotification *)notification;
{
	[arrayOfOperationQueues removeObject:[notification object]];
}

- (void)updateActivityWindowStats;
{
	[numberOfNSOperationQueuesTextField setStringValue:[[NSNumber numberWithInt:[arrayOfOperationQueues count]] stringValue]];
	
	int NSOperationCount = 0;
	NSOperationQueue *currentOperationQueue = nil;
	for (currentOperationQueue in arrayOfOperationQueues) {
		NSOperationCount += [[currentOperationQueue operations] count];
	}
	
	[numberOfNSOperationsTextField setStringValue:[[NSNumber numberWithInt:NSOperationCount] stringValue]];
}

- (IBAction)createNewBidirectionalCheckerWindow:(id)sender;
{
	EPBidirectionalCheckerController *newBidirectionalController = [[EPBidirectionalCheckerController alloc] init];
	[newBidirectionalController showWindow:self];
	[newBidirectionalController release];
}

- (IBAction)createNewTwittererChainFinderWindow:(id)sender;
{
	EPTwittererChainFinderController *newTwittererChainFinderController = [[EPTwittererChainFinderController alloc] init];
	[newTwittererChainFinderController showWindow:self];
	[newTwittererChainFinderController release];
}

- (IBAction)createNewFriendRecommenderWindow:(id)sender;
{
	EPFriendRecommenderController *newFriendRecommenderController = [[EPFriendRecommenderController alloc] init];
	[newFriendRecommenderController showWindow:self];
	[newFriendRecommenderController release];
}

- (IBAction)createNewTwittererMapperWindow:(id)sender;
{
	EPTwittererMapperController *newTwittererMapperController = [[EPTwittererMapperController alloc] init];
	[newTwittererMapperController showWindow:self];
	[newTwittererMapperController release];
}

@end
