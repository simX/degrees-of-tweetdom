//
//  EPFavoriteFinderController.m
//  Degrees of Tweetdom
//
//  Created by Simone Manganelli on 3/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "EPFavoriteFinderController.h"
#import "EPFavoriteFinder.h"


@implementation EPFavoriteFinderController

- (id)init;
{
	if (self = [super initWithWindowNibName:@"FavoriteFinder"]) {
		favoriteFinderInstance = [[EPFavoriteFinder alloc] initWithStatusDelegate:self];
	}
	
	return self;
}


- (void)dealloc;
{
	[favoriteFinderInstance release];
	[super dealloc];
}

- (IBAction)startAuthoredFavoritesRetrieval:(id)sender;
{
	[resultsView setString:@""];
	[self addStatusLine:[NSString stringWithFormat:@"Searching for favorited tweets authored by %@",[twittererTextField stringValue]]];
	
	[NSThread detachNewThreadSelector:@selector(findAuthoredFavorites) toTarget:self withObject:nil];
}

- (void)findAuthoredFavorites;
{
	NSDictionary *authoredFavoritesDict = [favoriteFinderInstance findFavoritesAuthoredByTwitterer:[twittererTextField stringValue]];
	NSDictionaryController *authedFavDictController = [[NSDictionaryController alloc] initWithContent:authoredFavoritesDict];
	NSArray *sortedAuthoredFavoritesArray = [[authedFavDictController arrangedObjects] sortedArrayUsingFunction:favoritersSortDescending context:nil];
	
	[authedFavDictController release];
	//NSLog(@"%@",sortedAuthoredFavoritesArray);
	
	
	NSMutableString *resultsString = [[NSMutableString alloc] init];
	id currentFav = nil;
	for (currentFav in sortedAuthoredFavoritesArray) {
		NSMutableString *favoritersString = [[NSMutableString alloc] init];
		NSArray *favoritersArray = [currentFav value];
		NSString *currentFavoriter = nil;
		for (currentFavoriter in favoritersArray) {
			[favoritersString appendString:[NSString stringWithFormat:@"%@, ",currentFavoriter]];
		}
		
		[resultsString appendString:[NSString stringWithFormat:@"%d twitterers (%@) favorited \"%@\"\n",[favoritersArray count],favoritersString,[currentFav key]]];
		 
		[favoritersString release];
	}
	
	[resultsView performSelectorOnMainThread:@selector(setString:) withObject:resultsString waitUntilDone:YES];
	[resultsString release];
}
		
int favoritersSortDescending(id firstFav, id secondFav, void *context)
{
	int result = NSOrderedSame; // initialize to some value
	int firstFavCount = [[firstFav value] count];
	int secondFavCount = [[secondFav value] count];
	
	if (firstFavCount < secondFavCount) {
		result = NSOrderedDescending;
	} else if (firstFavCount > secondFavCount) {
		result = NSOrderedAscending;
	} else if (firstFavCount == secondFavCount) {
		result = NSOrderedSame;
	}
	
	return result;
}

- (void)addStatusLine:(NSString *)statusLine;
{
	NSString *newStatus = [[resultsView string] stringByAppendingString:[NSString stringWithFormat:@"%@\n",statusLine]];
	
	[resultsView performSelectorOnMainThread:@selector(setString:) withObject:newStatus waitUntilDone:YES];
	[self performSelectorOnMainThread:@selector(scrollErrorConsoleToBottom) withObject:nil waitUntilDone:NO];
}

- (void)scrollErrorConsoleToBottom;
{
	[resultsView scrollRangeToVisible:NSMakeRange([[resultsView string] length]-1,1)];
}

@end
