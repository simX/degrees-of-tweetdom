//
//  EPFriendRecommenderController.m
//  Degrees of Tweetdom
//
//  Created by Simone Manganelli on 2008-08-26.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "EPFriendRecommenderController.h"
#import "EPFriendRecommender.h"


@implementation EPFriendRecommenderController

- (id)init;
{
	if (self = [super initWithWindowNibName:@"FriendRecommender"]) {
		friendRecommenderInstance = [[EPFriendRecommender alloc] initWithStatusDelegate:self];
	}
	
	return self;
}

- (void)dealloc;
{
	[friendRecommenderInstance release];
	
	[super dealloc];
}

- (void)addStatusLine:(NSString *)statusLine;
{
	NSString *newStatus = [[statusConsoleView string] stringByAppendingString:[NSString stringWithFormat:@"%@\n",statusLine]];
	
	[statusConsoleView performSelectorOnMainThread:@selector(setString:) withObject:newStatus waitUntilDone:YES];
	[self performSelectorOnMainThread:@selector(scrollErrorConsoleToBottom) withObject:nil waitUntilDone:NO];
}

- (void)scrollErrorConsoleToBottom;
{
	[statusConsoleView scrollRangeToVisible:NSMakeRange([[statusConsoleView string] length]-1,1)];
}

- (IBAction)startFriendRecommending:(id)sender;
{
	[statusConsoleView setString:@""];
	
	[NSThread detachNewThreadSelector:@selector(recommendSomeFriends)
							 toTarget:self
						   withObject:nil];
}

- (void)recommendSomeFriends;
{
	int levelsDeep = [levelsDeepTextField intValue];
	if (levelsDeep < 1) levelsDeep = 1;
	
	NSString *recommendationString = [friendRecommenderInstance recommendFriendsForTwitterer:[twittererTextField stringValue]
																				  levelsDeep:[NSNumber numberWithInt:levelsDeep]];
	
	[statusConsoleView performSelectorOnMainThread:@selector(setString:) withObject:recommendationString waitUntilDone:YES];
}

@end
