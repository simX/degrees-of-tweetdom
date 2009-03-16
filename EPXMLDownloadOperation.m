//
//  EPXMLDownloadOperation.m
//  Degrees of Tweetdom
//
//  Created by Simone Manganelli on 2008-04-13.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#define TURN_ON_HTML_SCRAPING 1
#import "EPXMLDownloadOperation.h"


@implementation EPXMLDownloadOperation

- (id)initWithStatusDelegate:(id)delegate;
{
	statusDelegate = delegate;
	
	return [self init];
}

- (id)init;
{
	if (self = [super init]) {
		twitterHandle = nil;
		twitterPassword = nil;
	}
	
	return self;
}

- (void)dealloc
{
	[twitterHandle release];
	[twitterPassword release];
	[super dealloc];
}

- (void)setTwitterHandle:(NSString *)newTwitterHandle;
{
	// we essentially copy the string because sometimes some NSOperations can be left
	// around even when the winning string has already been found, and that causes
	// the newTwitterHandle variable passed here to be released, and cause a crash
	
	twitterHandle = [newTwitterHandle retain];
}

// this method transforms the xml download operation into downloading the followers
// of the set twitter handle with the specified password
- (void)passwordForDownloadingFollowers:(NSString *)password;
{
	twitterPassword = [password retain];
}


- (void)main;
{
	if (TURN_ON_HTML_SCRAPING) {
		[self HTMLScrape];
	} else {
		[self XMLScrape];
	}
}


- (void)HTMLScrape;
{
	NSString *fullNonPaginatedURL = nil;
	NSString *fileLocationPath = nil;
	if (twitterPassword) {
		fileLocationPath = [[NSString stringWithFormat:@"~/Library/Caches/Degrees of Tweetdom/Followers/%@.plist",twitterHandle] stringByExpandingTildeInPath];
		fullNonPaginatedURL = [NSString stringWithFormat:@"http://twitter.com/%@/followers",twitterHandle,twitterPassword];
	} else {
		fileLocationPath = [[NSString stringWithFormat:@"~/Library/Caches/Degrees of Tweetdom/Friends/%@.plist",twitterHandle] stringByExpandingTildeInPath];
		fullNonPaginatedURL = [NSString stringWithFormat:@"http://twitter.com/%@/friends",twitterHandle];
	}
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:fileLocationPath]) {
		// the friends XML file has already been downloaded, so it doesn't need to be downloaded again
		
		// in the future, this block should check the modification date and recache the file if it's a week old or so
	} else {
		NSMutableArray *arrayOfFriends = [[NSMutableArray alloc] init];
		
		NSError *friendListError = nil;
		int pageNum = 1;
		BOOL noMoreFriends = NO;
		
		while (! noMoreFriends) {
			NSString *URLString = [fullNonPaginatedURL stringByAppendingString:[NSString stringWithFormat:@"?page=%d",pageNum]];
			NSXMLDocument *pageOfTwentyFriends = [[NSXMLDocument alloc] initWithContentsOfURL:[NSURL URLWithString:URLString]
																						  options:NSXMLDocumentTidyHTML
																							error:&friendListError];
			[pageOfTwentyFriends retain];
			

			// turns out NSXMLDocument returns warnings even if it successfully
			// converted to the NSXMLDocumentTidyHTML format, so we don't care
			// about these errors
			
			/*if (friendListError) {
				NSLog(@"%@",friendListError);
				[[NSNotificationCenter defaultCenter] postNotificationName:@"updateErrorConsole"
																	object:self
																  userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@\n",[friendListError localizedDescription]]
																									   forKey:@"error"]
				 ];
				noMoreFriends = YES;
			} else*/
			
			
			
			// the following code is structured this way because there were some random
			// hanging errors if I strung all the calls together at once; this may have been
			// due, however, to the fact that the friends.html and followers.html files were
			// structured slightly differently and I originally assumed they were
			// structured identically
			
			NSXMLNode *divNode = [[[pageOfTwentyFriends childAtIndex:0] childAtIndex:1] childAtIndex:3];
			[divNode detach];
			
			NSXMLNode *divNodeTwo = [divNode childAtIndex:4];
			[divNodeTwo detach];
		
			NSXMLNode *divNodeThree = [divNodeTwo childAtIndex:0];
			[divNodeThree detach];
		
			NSXMLNode *tableNode = nil;
			if (twitterPassword) {
				NSXMLNode *divNodeFour = [divNodeThree childAtIndex:0];
				[divNodeFour detach];
				
				tableNode = [divNodeFour childAtIndex:2];
				[tableNode detach];
			} else {
				tableNode = [divNodeThree childAtIndex:1];
				[tableNode detach];
			}
			
			if ([tableNode childCount] == 1) {
				// the hiearchy when this code was created is as follows:
				// html --> head --> body --> div id="container" --> div id="content" --> 
				// div class="wrapper" --> div id="followers" --> table class="follower-table doing"
				
				// this is the first page that returns no friends
				noMoreFriends = YES;
			} else {
				NSArray *potentialTwentyFriendsArray = [self extractFriendsFromTableNode:tableNode];
				if (potentialTwentyFriendsArray == nil) {
					// this could be a temporary error in retrieving the page;
					// error-handling could be improved here, but for now let's assume this means no more friends
					noMoreFriends = YES;
				} else {
					[arrayOfFriends addObjectsFromArray:potentialTwentyFriendsArray];
				}
			}
			
			[pageOfTwentyFriends setChildren:nil];
			[pageOfTwentyFriends release];
			[pageOfTwentyFriends release];
			
			
			//NSLog(@"pageNum for %@: %d",twitterHandle,pageNum);
			pageNum++;
		}
		
		//NSLog(@"Final list of friends for %@: %@",twitterHandle,arrayOfFriends);
		[arrayOfFriends writeToFile:fileLocationPath
						 atomically:YES];
		[arrayOfFriends release];
	}
}


- (void)XMLScrape;
{
	NSString *fullNonPaginatedURL = nil;
	NSString *fileLocationPath = nil;
	if (twitterPassword) {
		fileLocationPath = [[NSString stringWithFormat:@"~/Library/Caches/Degrees of Tweetdom/Followers/%@.plist",twitterHandle] stringByExpandingTildeInPath];
		fullNonPaginatedURL = [NSString stringWithFormat:@"http://%@:%@@twitter.com/statuses/followers.xml",twitterHandle,twitterPassword];
	} else {
		fileLocationPath = [[NSString stringWithFormat:@"~/Library/Caches/Degrees of Tweetdom/Friends/%@.plist",twitterHandle] stringByExpandingTildeInPath];
		fullNonPaginatedURL = [NSString stringWithFormat:@"http://twitter.com/statuses/friends/%@.xml",twitterHandle];
	}
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:fileLocationPath]) {
		// the friends XML file has already been downloaded, so it doesn't need to be downloaded again
		
		// in the future, this block should check the modification date and recache the file if it's a week old or so
	} else {
		NSMutableArray *arrayOfFriends = [[NSMutableArray alloc] init];
		
		NSError *friendListError = nil;
		int pageNum = 1;
		BOOL noMoreFriends = NO;
		
		while (! noMoreFriends) {
			NSString *URLString = [fullNonPaginatedURL stringByAppendingString:[NSString stringWithFormat:@"?page=%d",pageNum]];
			NSXMLDocument *pageOfOneHundredFriends = [[NSXMLDocument alloc] initWithContentsOfURL:[NSURL URLWithString:URLString]
																						  options:NSXMLDocumentTidyXML
																							error:&friendListError];
			
			if (friendListError) {
				[statusDelegate addStatusLine:[friendListError localizedDescription]];
				noMoreFriends = YES;
			} else if ([[[pageOfOneHundredFriends childAtIndex:0] name] isEqualToString:@"nil-classes"]) {
				// this is the first page that returns no friends
				noMoreFriends = YES;
			} else {
				NSArray *potentialOneHundredFriendsArray = [self extractFriendsFromXMLPage:pageOfOneHundredFriends];
				if (potentialOneHundredFriendsArray == nil) {
					// this could be a temporary error in retrieving the page;
					// error-handling could be improved here, but for now let's assume this means no more friends
					noMoreFriends = YES;
				} else {
					[arrayOfFriends addObjectsFromArray:potentialOneHundredFriendsArray];
				}
			}
			
			[pageOfOneHundredFriends setChildren:nil];
			[pageOfOneHundredFriends release];
			
			
			//NSLog(@"pageNum for %@: %d",twitterHandle,pageNum);
			pageNum++;
		}
		
		//NSLog(@"Final list of friends for %@: %@",twitterHandle,arrayOfFriends);
		[arrayOfFriends writeToFile:fileLocationPath
						 atomically:YES];
		[arrayOfFriends release];
	}
}

- (NSArray *)extractFriendsFromTableNode:(NSXMLNode *)tableNode;
{
	NSMutableArray *potentialTwentyFriendsArray = nil;
	
	if ([tableNode childCount] == 1) {
		// spurious problem page, perhaps?
	} else {
		NSArray *userObjects = [tableNode children];
		NSXMLNode *nextNode = nil;
		potentialTwentyFriendsArray = [[NSMutableArray alloc] init];
		
		for (nextNode in userObjects) {
			if (! [[nextNode name] isEqualToString:@"tr"]) {
				// this applies to the first empty text node
			} else {
				NSXMLElement *linkNode = (NSXMLElement *)[[nextNode childAtIndex:0] childAtIndex:0];
				NSString *possibleTwitterHandle = [[[[linkNode attributeForName:@"href"] stringValue] componentsSeparatedByString:@"http://twitter.com/"] objectAtIndex:1];
				[potentialTwentyFriendsArray addObject:possibleTwitterHandle];
			}
		}
	}
	
	return [potentialTwentyFriendsArray autorelease];
}

- (NSArray *)extractFriendsFromXMLPage:(NSXMLDocument *)pageOfOneHundredFriends;
{
	NSMutableArray *potentialOneHundredFriendsArray = nil;
	
	if ([[[pageOfOneHundredFriends childAtIndex:0] name] isEqualToString:@"nil-classes"]) {
		// this page does not contain any friends
	} else if ([[[pageOfOneHundredFriends childAtIndex:0] name] isEqualToString:@"html"]) {
		// this case probably happens when Twitter throws one of its spurious "there was a problem"
		// pages; reattempting the XML download would probably fix this problem
		
		//[self addStringToInAppErrorConsole:[NSString stringWithFormat:@"Error retrieving @%@'s friend list.\n",twitterHandle]];
	} else if (! [[[pageOfOneHundredFriends childAtIndex:0] name] isEqualToString:@"users"]) {
		/*[self addStringToInAppErrorConsole:[NSString stringWithFormat:@"Friends XML document in unexpected format for @%@.\n\tExpected 'users' child, encountered '%@' instead.\n"
		 ,twitterHandle,[[friendListXMLDoc childAtIndex:0] name]]];*/
	} else {
		NSArray *userObjects = [[pageOfOneHundredFriends childAtIndex:0] children];
		NSXMLNode *nextNode = nil;
		potentialOneHundredFriendsArray = [[NSMutableArray alloc] init];
		
		for (nextNode in userObjects) {
			if (! [[nextNode name] isEqualToString:@"user"]) {
				//[self addStringToInAppErrorConsole:[NSString stringWithFormat:@"Anomalous %@ node encountered.\n\tExpected 'user' instead.\n",[nextNode name]]];
			} else {
				NSXMLNode *friendHandleNode = [nextNode childAtIndex:2];
				if (! [[friendHandleNode name] isEqualToString:@"screen_name"]) {
					//[self addStringToInAppErrorConsole:[NSString stringWithFormat:@"Anomalous %@ node encountered.\n\tExpected 'screen_name' instead.\n",[friendHandleNode name]]];
				} else {
					[potentialOneHundredFriendsArray addObject:[friendHandleNode stringValue]];
				}
			}
		}
	}
	
	return [potentialOneHundredFriendsArray autorelease];
}

@end
