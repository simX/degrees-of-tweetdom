//
//  EPFavoriteFinder.m
//  Degrees of Tweetdom
//
//  Created by Simone Manganelli on 3/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "EPFavoriteFinder.h"
#import "EPFavoritesDownloadOperation.h"
#import "EPFriendAndFollowerGetter.h"


@implementation EPFavoriteFinder

- (id)initWithStatusDelegate:(id)delegate;
{
	statusDelegate = delegate;
	[self createCacheFolder];
	
	theMainOperationQueue = [[NSOperationQueue alloc] init];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"operationQueueCreated" object:theMainOperationQueue];
	
	friendAndFollowerGetterInstance = [[EPFriendAndFollowerGetter alloc] initWithStatusDelegate:statusDelegate];
	
	return [self init];
}


- (void)createCacheFolder;
{
	// make sure the folder where the Friends XML files are cached actually exists
	NSError *folderCreationError = nil;
	
	BOOL creationSucceeded = [[NSFileManager defaultManager] createDirectoryAtPath:[@"~/Library/Caches/Degrees of Tweetdom/Favorites/" stringByExpandingTildeInPath]
												  withIntermediateDirectories:YES
																   attributes:nil
																		error:&folderCreationError];
	
	if (! creationSucceeded) [statusDelegate addStatusLine:[folderCreationError localizedDescription]];	
}

- (NSDictionary *)findFavoritesAuthoredByTwitterer:(NSString *)twitterHandle;
{
	NSMutableDictionary *authoredFavoritesDict = [[NSMutableDictionary alloc] init];
	
	NSArray *friendsOfTwitterer = [friendAndFollowerGetterInstance getFriendsForTwitterer:twitterHandle];
	
	NSString *currentFriend = nil;
	for (currentFriend in friendsOfTwitterer) {
		[statusDelegate addStatusLine:[NSString stringWithFormat:@"Searching through favorites of %@",currentFriend]];
		NSArray *arrayOfFavorites = [self getFavoritesForTwitterer:currentFriend];
		
		NSDictionary *currentFavorite = nil;
		for (currentFavorite in arrayOfFavorites) {
			NSString *currentFavoriteBody = [currentFavorite objectForKey:@"favoriteBody"];
			NSString *currentFavoriteAuthor = [currentFavorite objectForKey:@"favoriteAuthor"];
			
			if ([currentFavoriteAuthor isEqualToString:twitterHandle]) {
				// we've found one of the twitterer's tweets that has been favorited!
				
				NSMutableArray *favoritersArray = [authoredFavoritesDict objectForKey:currentFavoriteBody];
				
				if (favoritersArray == nil) {
					// first time we've encountered this tweet being faved
					favoritersArray = [NSMutableArray arrayWithObject:currentFriend];
					[authoredFavoritesDict setObject:favoritersArray forKey:currentFavoriteBody];
				} else {
					// this tweet has been faved by someone else
					[favoritersArray addObject:currentFriend];
				}
			}
		}
	}
	
	//NSLog(@"%@",authoredFavoritesDict);
	return [authoredFavoritesDict autorelease];
}


- (NSArray *)getFavoritesForTwitterer:(NSString *)twitterHandle;
{
	NSString *XMLFileLocationPath = [[NSString stringWithFormat:@"~/Library/Caches/Degrees of Tweetdom/Favorites/%@.plist",twitterHandle] stringByExpandingTildeInPath];

	[self downloadFollowersForTwitterer:twitterHandle];
	int timeoutCounter = 0; 
	int maxTimeout = 60; // seconds to wait for an XML file to download
	
	while (! [[NSFileManager defaultManager] fileExistsAtPath:XMLFileLocationPath]) {
		
		timeoutCounter++;
		sleep(1);
		if (timeoutCounter >= maxTimeout) {
			[statusDelegate addStatusLine:[NSString stringWithFormat:@"Timed out waiting for %@'s Friend XML file to download.",twitterHandle]];
			break;
		}
	}
	
	NSArray *arrayOfFavorites = [NSArray arrayWithContentsOfFile:XMLFileLocationPath];
	
	return arrayOfFavorites;
}

- (void)downloadFollowersForTwitterer:(NSString *)twitterHandle;
{
	EPFavoritesDownloadOperation *downloadOperation = [[EPFavoritesDownloadOperation alloc] initWithStatusDelegate:self];
	[downloadOperation setTwitterHandle:twitterHandle];
	[theMainOperationQueue addOperation:downloadOperation];
	[downloadOperation release];
}

@end
