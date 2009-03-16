//
//  EPFriendRecommender.m
//  Degrees of Tweetdom
//
//  Created by Simone Manganelli on 2008-04-30.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "EPFriendRecommender.h"
#import "EPFriendAndFollowerGetter.h"


@implementation EPFriendRecommender

- (id)initWithStatusDelegate:(id)delegate;
{
	statusDelegate = delegate;
	
	return [self init];
}

- (void)addStatusLine:(NSString *)statusLine;
{
	[statusDelegate addStatusLine:statusLine];
}


- (NSString *)recommendFriendsForTwitterer:(NSString *)theTwitterer levelsDeep:(NSNumber *)levelsDeepNum;
{	
	EPFriendAndFollowerGetter *friendAndFollowerGetterInstance = 
		[[EPFriendAndFollowerGetter alloc] initWithStatusDelegate:self];
	
	NSArray *directFriendsOfTheTwitterer = [friendAndFollowerGetterInstance getFriendsForTwitterer:theTwitterer];
	NSMutableArray *twitterersToSearchArray = [[NSMutableArray alloc] init];
	NSMutableArray *twitterersAlreadySearchedArray = [[NSMutableArray alloc] init];
	NSMutableDictionary *friendRecommendations = [[NSMutableDictionary alloc] init];
	
	[twitterersToSearchArray addObjectsFromArray:directFriendsOfTheTwitterer];
	
	int i;
	int levelsDeep = [levelsDeepNum intValue];
	
	// structuring the loop parameters this way makes it easier for adding recommendation points
	for (i = levelsDeep; i > 0; i--) {
		[statusDelegate addStatusLine:[NSString stringWithFormat:@"Searching %d level(s) deep...\n",(levelsDeep - i + 1)]];
		
		NSString *nextTwittererToSearch = nil;
		for (nextTwittererToSearch in twitterersToSearchArray) {
			[friendAndFollowerGetterInstance downloadFriendsXMLFileForTwitterer:nextTwittererToSearch];
		}
		
		// copy the array so we can mutate the original within this enumeration loop
		NSArray *twitterersToSearchArrayCopy = [twitterersToSearchArray copy];
		
		for (nextTwittererToSearch in twitterersToSearchArrayCopy) {
			if (! [twitterersAlreadySearchedArray containsObject:nextTwittererToSearch]) {
				NSArray *indirectFriendsArray = [friendAndFollowerGetterInstance getFriendsForTwitterer:nextTwittererToSearch];
				
				NSString *indirectFriend = nil;
				for (indirectFriend in indirectFriendsArray) {
					NSNumber *numberOfRecommendations = [friendRecommendations objectForKey:indirectFriend];
					
					if (numberOfRecommendations == nil) {
						[friendRecommendations setObject:[NSNumber numberWithInt:1] forKey:indirectFriend];
					} else {
						[friendRecommendations setObject:[NSNumber numberWithInt:([numberOfRecommendations intValue] + i)]
												  forKey:indirectFriend];
					}
					
					[twitterersToSearchArray addObject:indirectFriend];
				}
				
				[twitterersAlreadySearchedArray addObject:nextTwittererToSearch];
			}
			
			[twitterersToSearchArray removeObject:nextTwittererToSearch];
		}
		
		[twitterersToSearchArrayCopy release];
	}
	
	NSString *nextDirectFriend = nil;
	// remove direct friends that we added to the dictionary in the first place
	for (nextDirectFriend in directFriendsOfTheTwitterer) {
		[friendRecommendations removeObjectForKey:nextDirectFriend];
	}
	
	// remove the twitterer himself
	[friendRecommendations removeObjectForKey:theTwitterer];
	
	NSMutableString *allRecommendationsString = [[NSMutableString alloc] init];
	
	NSArray *ascendingKeyArray = [friendRecommendations keysSortedByValueUsingSelector:@selector(compare:)];
	for (i = [ascendingKeyArray count] - 1; i >= 0; i--) {
		NSString *nextRecommendation = [ascendingKeyArray objectAtIndex:i];
		
		[allRecommendationsString appendString:[NSString stringWithFormat:@"%@ has %d recommendation points.\n"
												,nextRecommendation,[[friendRecommendations objectForKey:nextRecommendation] intValue]]];
	}
	
	[twitterersToSearchArray release];
	[twitterersAlreadySearchedArray release];
	[friendRecommendations release];
	
	return [allRecommendationsString autorelease];
}

@end
