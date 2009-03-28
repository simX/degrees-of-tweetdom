//
//  EPFavoriteFinder.h
//  Degrees of Tweetdom
//
//  Created by Simone Manganelli on 3/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class EPFriendAndFollowerGetter;
@class EPOperationQueue;


@interface EPFavoriteFinder : NSObject {
	id statusDelegate;
	EPOperationQueue *theMainOperationQueue;
	
	EPFriendAndFollowerGetter *friendAndFollowerGetterInstance;
}

- (id)initWithStatusDelegate:(id)delegate;
- (void)createCacheFolder;

- (NSDictionary *)findFavoritesAuthoredByTwitterer:(NSString *)twitterHandle;

- (NSArray *)getFavoritesForTwitterer:(NSString *)twitterHandle;
- (void)downloadFollowersForTwitterer:(NSString *)twitterHandle;

@end
