//
//  EPFavoritesDownloadOperation.m
//  Degrees of Tweetdom
//
//  Created by Simone Manganelli on 3/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "EPFavoritesDownloadOperation.h"


@implementation EPFavoritesDownloadOperation

- (id)initWithStatusDelegate:(id)delegate;
{
	statusDelegate = delegate;
	
	return [self init];
}

- (id)init;
{
	if (self = [super init]) {
		twitterHandle = nil;
	}
	
	return self;
}

- (void)dealloc
{
	[twitterHandle release];
	[super dealloc];
}


- (void)setTwitterHandle:(NSString *)newTwitterHandle;
{
	twitterHandle = @"stalefries";
	//twitterHandle = [newTwitterHandle retain];
}


- (void)main;
{
	NSString *fullNonPaginatedURL = [NSString stringWithFormat:@"http://twitter.com/%@/favourites",twitterHandle];
	NSString *fileLocationPath = [[NSString stringWithFormat:@"~/Library/Caches/Degrees of Tweetdom/Favorites/%@.plist",twitterHandle] stringByExpandingTildeInPath];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:fileLocationPath]) {
		// the friends XML file has already been downloaded, so it doesn't need to be downloaded again
		
		// in the future, this block should check the modification date and recache the file if it's a week old or so
	} else {
		
		// main part of the download operation
		NSMutableArray *arrayOfFavorites = [[NSMutableArray alloc] init];
		
		NSError *favoritesListError = nil;
		int pageNum = 1;
		BOOL noMoreFavorites = NO;
		
		while (! noMoreFavorites) {
			NSString *URLString = [fullNonPaginatedURL stringByAppendingString:[NSString stringWithFormat:@"?page=%d",pageNum]];
			NSXMLDocument *pageOfTwentyFriends = [[NSXMLDocument alloc] initWithContentsOfURL:[NSURL URLWithString:URLString]
																					  options:NSXMLDocumentTidyHTML
																						error:&favoritesListError];
			
			//NSLog(@"%@",pageOfTwentyFriends);
			NSError *xPathError = nil;
			NSArray *favoriteLiNodeArray = [pageOfTwentyFriends nodesForXPath:@".//span[@class='status-body']" error:&xPathError];
			
			//NSLog(@"%@",favoriteLiNodeArray);
			if (xPathError) NSLog(@"%@",xPathError);
			xPathError = nil;
			
			if ([favoriteLiNodeArray count] < 20) noMoreFavorites = YES;
			// there could be fewer than 20 favorites more, but more than 0, so we still want to process
			
			
			NSXMLNode *currentNode = nil;
			for (currentNode in favoriteLiNodeArray) {
				NSXMLNode *bodyNode = [[currentNode nodesForXPath:@".//span[@class='entry-content']" error:&xPathError] objectAtIndex:0];
				if (xPathError) NSLog(@"%@",xPathError);
				xPathError = nil;
				
				NSString *favoriteBody = [bodyNode stringValue];
				//NSLog(@"favoriteBody = %@",favoriteBody);
				
				
				NSXMLNode *authorNode = [[currentNode nodesForXPath:@".//a[@class='screen-name']" error:&xPathError] objectAtIndex:0];
				if (xPathError) NSLog(@"%@",xPathError);
				xPathError = nil;
				
				NSString *favoriteAuthorLink = [[(NSXMLElement *)authorNode attributeForName:@"href"] stringValue];
				NSString *favoriteAuthor = [[favoriteAuthorLink componentsSeparatedByString:@"http://twitter.com/"] objectAtIndex:1];
				//NSLog(@"favoriteAuthor = %@",favoriteAuthor);
				
				NSDictionary *favoriteDict = [NSDictionary dictionaryWithObjectsAndKeys:favoriteBody,@"favoriteBody",favoriteAuthor,@"favoriteAuthor",nil];
				[arrayOfFavorites addObject:favoriteDict];
			}
			
			pageNum++;
			
		}
		
		[arrayOfFavorites writeToFile:fileLocationPath
						   atomically:YES];
		[arrayOfFavorites release];
	}
}


@end
