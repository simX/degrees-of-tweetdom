//
//  EPFriendRecommender.h
//  Degrees of Tweetdom
//
//  Created by Simone Manganelli on 2008-04-30.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface EPFriendRecommender : NSObject {
	id statusDelegate;
}

- (id)initWithStatusDelegate:(id)delegate;
- (void)addStatusLine:(NSString *)statusLine;

- (NSString *)recommendFriendsForTwitterer:(NSString *)theTwitterer levelsDeep:(NSNumber *)levelsDeepNum;

@end
