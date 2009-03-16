//
//  EPTweetChainFinder.h
//  Degrees of Tweetdom
//
//  Created by Simone Manganelli on 2008-04-09.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
@class EPTwittererChain;
@class CPriorityQueue;
@class EPTwittererMapHintStore;


@interface EPTwittererChainFinder : NSObject {
	int maxConcurrentOperations;
	NSOperationQueue *theMainOperationQueue;
	NSMutableArray *pastTwitterersArray;
	
	id statusDelegate;
}

- (id)initWithStatusDelegate:(id)delegate;
- (void)addStatusLine:(NSString *)statusLine;

- (void)findShortestPathWithStartTwitterers:(NSArray *)startTwitterers endTwitterers:(NSArray *)endTwitterers;
- (NSArray *)findShortestPathFrom:(NSString *)startTwitterer
							   to:(NSArray *)endTwitterers
						excluding:(NSArray *)twitterersToExclude
			    usingMapHintStore:(EPTwittererMapHintStore **)mapHintStore;
- (NSArray *)findShortestPathUsingTweetChainQueue:(CPriorityQueue *)tweetChainQueue
									 endTwitterer:(NSArray *)endTwitterers
										excluding:(NSArray *)twitterersToExclude
								usingMapHintStore:(EPTwittererMapHintStore **)mapHintStore;
- (BOOL)checkForEndTwitterersOneChainDeeperUsingInitialPath:(EPTwittererChain *)initialTweetChain
											tweetChainQueue:(CPriorityQueue *)tweetChainQueue
											  endTwitterers:(NSMutableArray **)endTwitterers
												  excluding:(NSArray *)twitterersToExclude
										 winningChainsArray:(NSMutableArray **)winningChainsArrayRef
											   mapHintStore:(EPTwittererMapHintStore **)mapHintStore;
- (NSArray *)validateTwitterNames:(NSArray *)twitterersToValidate;
- (NSString *)validateTwitterName:(NSString *)twitterHandle;

@end
