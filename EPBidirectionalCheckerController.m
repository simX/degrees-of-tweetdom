//
//  EPBidirectionalCheckerController.m
//  Degrees of Tweetdom
//
//  Created by Simone Manganelli on 2008-08-22.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "EPBidirectionalCheckerController.h"
#import "EPBidirectionalChecker.h"


@implementation EPBidirectionalCheckerController

- (id)init;
{
	if (self = [super initWithWindowNibName:@"BidirectionalChecker"]) {
		bidirectionalCheckerInstance = [[EPBidirectionalChecker alloc] initWithStatusDelegate:self];
	}
	
	return self;
}

- (void)dealloc;
{
	[bidirectionalCheckerInstance release];
	[super dealloc];
}

- (void)addStatusLine:(NSString *)statusLine;
{
	NSString *newStatus = [[statsTextView string] stringByAppendingString:[NSString stringWithFormat:@"%@\n",statusLine]];
	
	[statsTextView performSelectorOnMainThread:@selector(setString:) withObject:newStatus waitUntilDone:YES];
	[self performSelectorOnMainThread:@selector(scrollErrorConsoleToBottom) withObject:nil waitUntilDone:NO];
}

- (void)scrollErrorConsoleToBottom;
{
	[statsTextView scrollRangeToVisible:NSMakeRange([[statsTextView string] length]-1,1)];
}


- (IBAction)startBidirectionalStatsRetrieval:(id)sender;
{
	[statsTextView setString:@""];
	
	[NSThread detachNewThreadSelector:@selector(retrieveBidirectionalStats) toTarget:self withObject:nil];
}

- (void)retrieveBidirectionalStats;
{
	NSString *bidirectionalStatsString = [bidirectionalCheckerInstance getFriendAndFollowerRelationshipStatsForTwitterer:[twittererHandleTextField stringValue]
																						   passwordSecureTextField:twittererPasswordTextField];
	
	[statsTextView performSelectorOnMainThread:@selector(setString:) withObject:bidirectionalStatsString waitUntilDone:YES];
}

@end
