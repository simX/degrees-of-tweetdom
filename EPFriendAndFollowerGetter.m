//
//  EPFriendAndFollowerGetter.m
//  Degrees of Tweetdom
//
//  Created by Simone Manganelli on 2008-08-20.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "EPFriendAndFollowerGetter.h"
#import "EPXMLDownloadOperation.h"
#import "EPOperationQueue.h"


@implementation EPFriendAndFollowerGetter

- (id)init;
{
	if (self = [super init]) {
		theMainOperationQueue = [[EPOperationQueue alloc] init];
		
		[self createCacheFolders];
		//[[NSNotificationCenter defaultCenter] postNotificationName:@"operationQueueCreated" object:theMainOperationQueue];
	}
	
	return self;
}

- (id)initWithStatusDelegate:(id)delegate;
{
	if (self = [super init]) {
		statusDelegate = delegate;
		theMainOperationQueue = [[EPOperationQueue alloc] init];
		
		[self createCacheFolders];
		//[[NSNotificationCenter defaultCenter] postNotificationName:@"operationQueueCreated" object:theMainOperationQueue];
	}
	
	return self;
}

- (id)initWithStatusDelegate:(id)delegate andOperationQueue:(EPOperationQueue *)operationQueue;
{
	if (self = [super init]) {
		statusDelegate = delegate;
		theMainOperationQueue = operationQueue;
		[theMainOperationQueue retain];
		
		[self createCacheFolders];
	}
	
	return self;
}

- (void)dealloc;
{
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"operationQueueCreated" object:theMainOperationQueue];
	[theMainOperationQueue release];
	
	[super dealloc];
}

- (void)addStatusLine:(NSString *)statusLine;
{
	[statusDelegate addStatusLine:statusLine];
}

- (void)createCacheFolders;
{
	// make sure the folder where the Friends XML files are cached actually exists
	NSError *folderCreationError = nil;
	BOOL creationSucceeded = [[NSFileManager defaultManager] createDirectoryAtPath:[@"~/Library/Caches/Degrees of Tweetdom/Friends/" stringByExpandingTildeInPath]
													   withIntermediateDirectories:YES
																		attributes:nil
																			 error:&folderCreationError];
	
	if (! creationSucceeded) [statusDelegate addStatusLine:[folderCreationError localizedDescription]];
	
	creationSucceeded = [[NSFileManager defaultManager] createDirectoryAtPath:[@"~/Library/Caches/Degrees of Tweetdom/Followers/" stringByExpandingTildeInPath]
												  withIntermediateDirectories:YES
																   attributes:nil
																		error:&folderCreationError];
	
	if (! creationSucceeded) [statusDelegate addStatusLine:[folderCreationError localizedDescription]];	
}


- (NSArray *)getFriendsForTwitterer:(NSString *)twitterHandle;
{
	return [self getFriendsForTwitterer:twitterHandle followersWithPassword:nil];
}


- (NSArray *)getFollowersForTwitterer:(NSString *)twitterHandle withPassword:(NSString *)twitterPassword;
{
	return [self getFriendsForTwitterer:twitterHandle followersWithPassword:twitterPassword];
}


// this method returns an array of friends for a given twitterer if no password is given,
// and an array of followers for a given twitter if a password *is* given
- (NSArray *)getFriendsForTwitterer:(NSString *)twitterHandle followersWithPassword:(NSString *)twitterPassword;
{
	NSString *XMLFileLocationPath = nil;
	if (twitterPassword) {
		XMLFileLocationPath = [[NSString stringWithFormat:@"~/Library/Caches/Degrees of Tweetdom/Followers/%@.plist",twitterHandle] stringByExpandingTildeInPath];
		[self downloadFollowersXMLFileForTwitterer:twitterHandle withPassword:twitterPassword];
	} else {
		// twitterPassword is nil; no password needed for downloading friends files
		XMLFileLocationPath = [[NSString stringWithFormat:@"~/Library/Caches/Degrees of Tweetdom/Friends/%@.plist",twitterHandle] stringByExpandingTildeInPath];
		[self downloadFriendsXMLFileForTwitterer:twitterHandle];
	}
		
	//NSError *friendListError = nil;
	int timeoutCounter = 0; 
	int maxTimeout = 60; // seconds to wait for an XML file to download
	
	while (! [[NSFileManager defaultManager] fileExistsAtPath:XMLFileLocationPath]) {
		// the friends XML files are written atomically by the spun off threads;
		// thus, when the file exists, it's been completly written and so it's ready to be
		// read by this method -- so the only check we need to do is to see if the file exists
		
		// however, if there was an error downloading the XML file, we want a timeout, else
		// the program might wait forever for a certain XML file
		
		timeoutCounter++;
		sleep(1);
		if (timeoutCounter >= maxTimeout) {
			[statusDelegate addStatusLine:[NSString stringWithFormat:@"Timed out waiting for %@'s Friend XML file to download.",twitterHandle]];
			break;
		}
	}
	
	NSArray *arrayOfFriends = [NSArray arrayWithContentsOfFile:XMLFileLocationPath];
	
	return arrayOfFriends;
}

- (void)downloadFriendsXMLFileForTwitterer:(NSString *)twitterHandle;
{
	EPXMLDownloadOperation *downloadOperation = [[EPXMLDownloadOperation alloc] initWithStatusDelegate:self];
	[downloadOperation setTwitterHandle:twitterHandle];
	[theMainOperationQueue addOperation:downloadOperation];
	[downloadOperation release];
}


- (void)downloadFollowersXMLFileForTwitterer:(NSString *)twitterHandle withPassword:(NSString *)twitterPassword;
{
	EPXMLDownloadOperation *downloadOperation = [[EPXMLDownloadOperation alloc] initWithStatusDelegate:self];
	[downloadOperation setTwitterHandle:twitterHandle];
	[downloadOperation passwordForDownloadingFollowers:twitterPassword];
	[theMainOperationQueue addOperation:downloadOperation];
	[downloadOperation release];
}

@end
