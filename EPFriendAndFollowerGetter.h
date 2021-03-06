//
//  EPFriendAndFollowerGetter.h
//  Degrees of Tweetdom
//
//  Created by Simone Manganelli on 2008-08-20.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class EPOperationQueue;


@interface EPFriendAndFollowerGetter : NSObject {
	EPOperationQueue *theMainOperationQueue;
	id statusDelegate;
}

- (id)initWithStatusDelegate:(id)delegate;
- (id)initWithStatusDelegate:(id)delegate andOperationQueue:(EPOperationQueue *)operationQueue;

- (void)createCacheFolders;

- (NSArray *)getFriendsForTwitterer:(NSString *)twitterHandle;
- (NSArray *)getFollowersForTwitterer:(NSString *)twitterHandle withPassword:(NSString *)twitterPassword;
- (NSArray *)getFriendsForTwitterer:(NSString *)twitterHandle followersWithPassword:(NSString *)twitterPassword;

- (void)downloadFriendsXMLFileForTwitterer:(NSString *)twitterHandle;
- (void)downloadFollowersXMLFileForTwitterer:(NSString *)twitterHandle withPassword:(NSString *)twitterPassword;

- (void)addStatusLine:(NSString *)statusLine;

@end
