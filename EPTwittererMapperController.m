//
//  EPTwittererMapperController.m
//  Degrees of Tweetdom
//
//  Created by Simone Manganelli on 2008-08-26.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "EPTwittererMapperController.h"
#import "EPTwittererMapper.h"


@implementation EPTwittererMapperController

- (id)init;
{
	if (self = [super initWithWindowNibName:@"TwittererMapper"]) {
		twittererMapperInstance = [[EPTwittererMapper alloc] initWithStatusDelegate:self];
	}
	
	return self;
}

- (void)dealloc;
{
	[twittererMapperInstance release];
	
	[super dealloc];
}

- (void)awakeFromNib;
{
	[mapImageView setAllowsCutCopyPaste:YES];
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


- (IBAction)startTwitterMapping:(id)sender;
{
	[errorConsoleView setString:@""];
	
	[NSThread detachNewThreadSelector:@selector(createMap)
							 toTarget:self
						   withObject:nil];
}

- (void)createMap;
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSArray *twitterersArray = [[twitterersToMapTextField stringValue] componentsSeparatedByString:@","];
	NSArray *twittererExclusions = [[twitterersToExcludeTextField stringValue] componentsSeparatedByString:@","];
	
	NSImage *twittererMap = [twittererMapperInstance createMapOfTwitterers:twitterersArray excluding:twittererExclusions];
	[mapImageView performSelectorOnMainThread:@selector(setImage:) withObject:twittererMap waitUntilDone:YES];
	
	[pool release];
}

@end
