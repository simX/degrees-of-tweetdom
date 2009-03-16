//
//  EPXMLDownloadOperation.h
//  Degrees of Tweetdom
//
//  Created by Simone Manganelli on 2008-04-13.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface EPXMLDownloadOperation : NSOperation {
	NSString *twitterHandle;
	NSTextView *statusTextView;
	
	NSString *twitterPassword;
	
	id statusDelegate;
}

- (id)initWithStatusDelegate:(id)delegate;

- (void)setTwitterHandle:(NSString *)newTwitterHandle;
- (void)passwordForDownloadingFollowers:(NSString *)password;

- (void)HTMLScrape;
- (void)XMLScrape;

- (NSArray *)extractFriendsFromTableNode:(NSXMLNode *)tableNode;
- (NSArray *)extractFriendsFromXMLPage:(NSXMLDocument *)pageOfOneHundredFriends;

@end
