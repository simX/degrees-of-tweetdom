//
//  EPBidirectionalChecker.h
//  Degrees of Tweetdom
//
//  Created by Simone Manganelli on 2008-08-20.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class EPFriendAndFollowerGetter;


@interface EPBidirectionalChecker : NSObject {
	EPFriendAndFollowerGetter *friendAndFollowerGetterInstance;
	id statusDelegate;
}

- (id)initWithStatusDelegate:(id)delegate;
- (void)addStatusLine:(NSString *)statusLine;

- (NSString *)getFriendAndFollowerRelationshipStatsForTwitterer:(NSString *)twitterHandle
										passwordSecureTextField:(NSSecureTextField *)twittererPasswordTextField;


- (NSSet *)bidirectionalFriendsForTwitterer:(NSString *)twitterHandle
					passwordSecureTextField:(NSSecureTextField *)twittererPasswordTextField;

- (NSSet *)followersWhoArentFriendsForTwitterer:(NSString *)twitterHandle
						passwordSecureTextField:(NSSecureTextField *)twittererPasswordTextField;

- (NSSet *)friendsWhoArentFollowersForTwitterer:(NSString *)twitterHandle
						passwordSecureTextField:(NSSecureTextField *)twittererPasswordTextField;

@end
