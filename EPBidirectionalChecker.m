//
//  EPBidirectionalChecker.m
//  Degrees of Tweetdom
//
//  Created by Simone Manganelli on 2008-08-20.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "EPBidirectionalChecker.h"
#import "EPFriendAndFollowerGetter.h"


@implementation EPBidirectionalChecker

- (id)initWithStatusDelegate:(id)delegate;
{
	statusDelegate = delegate;
	
	return [self init];
}

- (id)init;
{
	if (self = [super init]) {
		friendAndFollowerGetterInstance = [[EPFriendAndFollowerGetter alloc] initWithStatusDelegate:self];
	}
	
	return self;
}

- (void)dealloc;
{
	[friendAndFollowerGetterInstance release];
	
	[super dealloc];
}

- (void)addStatusLine:(NSString *)statusLine;
{
	[statusDelegate addStatusLine:statusLine];
}

- (NSString *)getFriendAndFollowerRelationshipStatsForTwitterer:(NSString *)twitterHandle
										passwordSecureTextField:(NSSecureTextField *)twittererPasswordTextField;
{
	
	NSSet *friendsSet = [NSMutableSet setWithArray:[friendAndFollowerGetterInstance getFriendsForTwitterer:twitterHandle]];
	NSSet *followersSet = [NSSet setWithArray:[friendAndFollowerGetterInstance getFollowersForTwitterer:twitterHandle withPassword:[twittererPasswordTextField stringValue]]];
	
	NSSet *bidirectionalFriendsSet = [self bidirectionalFriendsForTwitterer:twitterHandle passwordSecureTextField:twittererPasswordTextField];
	NSSet *friendsNotFollowersSet = [self friendsWhoArentFollowersForTwitterer:twitterHandle passwordSecureTextField:twittererPasswordTextField];
	NSSet *followersNotFriendsSet = [self followersWhoArentFriendsForTwitterer:twitterHandle passwordSecureTextField:twittererPasswordTextField];
	
	NSMutableString *statsString = [[NSMutableString alloc] init];
	
	[statsString appendString:[NSString stringWithFormat:@"People you follow who follow you back: %@\n",bidirectionalFriendsSet]];
	[statsString appendString:[NSString stringWithFormat:@"People you follow who don't follow you back: %@\n",friendsNotFollowersSet]];
	[statsString appendString:[NSString stringWithFormat:@"People you don't follow who follow you back: %@\n\n",followersNotFriendsSet]];
	
	if ([friendsSet count] == 0) {
		[statusDelegate addStatusLine:[NSString stringWithFormat:@"Error: @%@ has no friends or there was a problem retrieving the list of friends.",twitterHandle]];
	} else {
		[statsString appendString:[NSString stringWithFormat:@"Percentage of people you follow who follow you back: %d%%\n",[bidirectionalFriendsSet count]*100/[friendsSet count]]];
	}
	
	if ([followersSet count] == 0) {
		[statusDelegate addStatusLine:[NSString stringWithFormat:@"Error: @%@ has no followers or there was a problem retrieving the list of followers.",twitterHandle]];
	} else {
		[statsString appendString:[NSString stringWithFormat:@"Percentage of people who follow you who you also follow: %d%%\n",[bidirectionalFriendsSet count]*100/[followersSet count]]];
	}
	
	return [statsString autorelease];
}


- (NSSet *)bidirectionalFriendsForTwitterer:(NSString *)twitterHandle
					passwordSecureTextField:(NSSecureTextField *)twittererPasswordTextField;
{
	NSMutableSet *friendsSet = [NSMutableSet setWithArray:[friendAndFollowerGetterInstance getFriendsForTwitterer:twitterHandle]];
	NSSet *followersSet = [NSSet setWithArray:[friendAndFollowerGetterInstance getFollowersForTwitterer:twitterHandle
																						   withPassword:[twittererPasswordTextField stringValue]]];

	[friendsSet intersectSet:followersSet];
	return friendsSet;
}

- (NSSet *)followersWhoArentFriendsForTwitterer:(NSString *)twitterHandle
						passwordSecureTextField:(NSSecureTextField *)twittererPasswordTextField;
{
	NSMutableSet *followersSet = [NSMutableSet setWithArray:[friendAndFollowerGetterInstance getFollowersForTwitterer:twitterHandle
																										 withPassword:[twittererPasswordTextField stringValue]]];
	NSSet *friendsSet = [NSSet setWithArray:[friendAndFollowerGetterInstance getFriendsForTwitterer:twitterHandle]];

	[followersSet minusSet:friendsSet];
	return followersSet;
}

- (NSSet *)friendsWhoArentFollowersForTwitterer:(NSString *)twitterHandle
						passwordSecureTextField:(NSSecureTextField *)twittererPasswordTextField;
{
	NSMutableSet *friendsSet = [NSMutableSet setWithArray:[friendAndFollowerGetterInstance getFriendsForTwitterer:twitterHandle]];
	NSSet *followersSet = [NSSet setWithArray:[friendAndFollowerGetterInstance getFollowersForTwitterer:twitterHandle
																						   withPassword:[twittererPasswordTextField stringValue]]];
	
	[friendsSet minusSet:followersSet];
	return friendsSet;
}

@end
