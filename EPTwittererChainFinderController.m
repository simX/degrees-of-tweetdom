//
//  EPTwittererChainFinderController.m
//  Degrees of Tweetdom
//
//  Created by Simone Manganelli on 2008-08-24.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "EPTwittererChainFinderController.h"
#import "EPTwittererChainFinder.h"


@implementation EPTwittererChainFinderController

- (id)init;
{
	if (self = [super initWithWindowNibName:@"TwittererChainFinder"]) {
		twittererChainFinderInstance = [[EPTwittererChainFinder alloc] initWithStatusDelegate:self];
	}
	
	return self;
}

- (void)dealloc;
{
	[twittererChainFinderInstance release];
	
	[super dealloc];
}

- (void)addStatusLine:(NSString *)statusLine;
{
	NSString *newStatus = [[errorConsoleView string] stringByAppendingString:[NSString stringWithFormat:@"%@\n",statusLine]];
	
	[errorConsoleView performSelectorOnMainThread:@selector(setString:) withObject:newStatus waitUntilDone:YES];
	[self performSelectorOnMainThread:@selector(scrollErrorConsoleToBottom) withObject:nil waitUntilDone:NO];
}

- (void)scrollErrorConsoleToBottom;
{
	[errorConsoleView scrollRangeToVisible:NSMakeRange([[errorConsoleView string] length]-1,1)];
}

- (IBAction)startChainSearch:(id)sender;
{
	[errorConsoleView setString:@""];
	
	[NSThread detachNewThreadSelector:@selector(doChainSearch)
							 toTarget:self
						   withObject:nil];
}

- (void)doChainSearch;
{
	NSArray *startTwitterers = [NSArray arrayWithObject:[firstTwittererTextField stringValue]];
	NSArray *endTwitterers = [NSArray arrayWithObject:[secondTwittererTextField stringValue]];
	
	[twittererChainFinderInstance findShortestPathWithStartTwitterers:startTwitterers endTwitterers:endTwitterers];
}

@end
