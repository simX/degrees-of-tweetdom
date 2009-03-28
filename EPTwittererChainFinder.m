//
//  EPTweetChainFinder.m
//  Degrees of Tweetdom
//
//  Created by Simone Manganelli on 2008-04-09.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "EPTwittererChainFinder.h"
#import "CPriorityQueue.h"
#import "EPTwittererChain.h"
#import "EPXMLDownloadOperation.h"
#import "EPTwittererMapHintStore.h"
#import "EPFriendAndFollowerGetter.h"
//#define MAX_CONCURRENT_OPERATIONS_ALLOWED 30
#define TURN_ON_HTML_SCRAPING 1


@implementation EPTwittererChainFinder

- (id)initWithStatusDelegate:(id)delegate;
{
	statusDelegate = delegate;
	
	return [self init];
}

- (id)init;
{
	if (self = [super init]) {
		theMainOperationQueue = [[NSOperationQueue alloc] init];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"operationQueueCreated" object:theMainOperationQueue];
		
		//[theMainOperationQueue setMaxConcurrentOperationCount:MAX_CONCURRENT_OPERATIONS_ALLOWED];
		pastTwitterersArray = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void)dealloc;
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"operationQueueDeleted" object:theMainOperationQueue];
	[theMainOperationQueue release];
	[pastTwitterersArray release];
	[super dealloc];
}


- (void)addStatusLine:(NSString *)statusLine;
{
	[statusDelegate addStatusLine:statusLine];
}


- (void)findShortestPathWithStartTwitterers:(NSArray *)startTwitterers endTwitterers:(NSArray *)endTwitterers;
{
	// let's make sure all the twitterers names are valid
	NSArray *validatedStartTwittererArray = [self validateTwitterNames:startTwitterers];
	NSArray *validatedEndTwitterers = [self validateTwitterNames:endTwitterers];
	
	[self findShortestPathFrom:[validatedStartTwittererArray objectAtIndex:0]
							to:validatedEndTwitterers
					 excluding:[NSArray array]
			 usingMapHintStore:nil];
}

- (NSArray *)findShortestPathFrom:(NSString *)startTwitterer
							   to:(NSArray *)endTwitterers
						excluding:(NSArray *)twitterersToExclude
			    usingMapHintStore:(EPTwittererMapHintStore **)mapHintStore;
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *validatedStartTwitterer = [[self validateTwitterNames:[NSArray arrayWithObject:startTwitterer]] objectAtIndex:0];
	NSArray *validatedEndTwitterers = [self validateTwitterNames:endTwitterers];
	NSArray *validatedExcludedTwitterers = [self validateTwitterNames:twitterersToExclude];
	
	[theMainOperationQueue cancelAllOperations];
	
	NSArray *theWinningChainsArray = nil;
	
	if ([validatedEndTwitterers count] < 1) {
		// invalid search, we need at least one end twitterer
	} else {
		NSMutableString *searchParametersConsoleString = [[NSMutableString alloc] init];
		[searchParametersConsoleString appendString:[NSString stringWithFormat:@"Starting from twitterer: %@,\nEnding at twitterers: ",
													 validatedStartTwitterer]];
		
		NSString *nextTwitterer = nil;
		
		for (nextTwitterer in validatedEndTwitterers) {
			[searchParametersConsoleString appendString:[NSString stringWithFormat:@"%@, ",nextTwitterer]];
		}
		
		[searchParametersConsoleString appendString:@"\nExcluding twitterers: "];
		
		for (nextTwitterer in validatedExcludedTwitterers) {
			[searchParametersConsoleString appendString:[NSString stringWithFormat:@"%@, ",nextTwitterer]];
		}
		
		[statusDelegate addStatusLine:searchParametersConsoleString];
		[searchParametersConsoleString release];
		
		CPriorityQueue *tweetChainQueue = [[CPriorityQueue alloc] init];
		[tweetChainQueue setPriorityKey:@"pathLength"];
		
		EPTwittererChain *rootTweetChain = [[EPTwittererChain alloc] init];
		[rootTweetChain setRootTwitterer:validatedStartTwitterer];
		
		[tweetChainQueue addObject:rootTweetChain];
		[rootTweetChain release];
		
		
		// prefetch the friends file for the initial twitterer
		EPXMLDownloadOperation *downloadOperation = [[EPXMLDownloadOperation alloc] initWithStatusDelegate:self];
		[downloadOperation setTwitterHandle:validatedStartTwitterer];
		[theMainOperationQueue addOperation:downloadOperation];
		[downloadOperation release];
		 
		// make sure that we clear the history from past degrees of separation searches
		[pastTwitterersArray removeAllObjects];
		theWinningChainsArray = [self findShortestPathUsingTweetChainQueue:tweetChainQueue
																  endTwitterer:validatedEndTwitterers
																	 excluding:validatedExcludedTwitterers
														 usingMapHintStore:mapHintStore];
		[theWinningChainsArray retain];
		
		// just in case, clear the past twitterers array again and cancel all remaining operations
		[pastTwitterersArray removeAllObjects];
		[theMainOperationQueue cancelAllOperations];
		
		[tweetChainQueue release];
	}
	
	// weird EXC_BAD_INSTRUCTION error occurs if you don't copy the array and return an
	// autoreleased copy when run in non-GC mode; from what I can tell, I haven't over-released
	// anywhere, but it's getting the assertion when trying to retain the array from the
	// EPTwittererMapper object (which is incidentally on another thread, which might be causing
	// the problem?)
	
	NSArray *returnArray = [theWinningChainsArray copy];
	[pool release];
	return [returnArray autorelease];
}


- (NSArray *)findShortestPathUsingTweetChainQueue:(CPriorityQueue *)tweetChainQueue
									 endTwitterer:(NSArray *)endTwitterers
										excluding:(NSArray *)twitterersToExclude
								usingMapHintStore:(EPTwittererMapHintStore **)mapHintStore;
{
	NSMutableArray *theWinningChains = [[NSMutableArray alloc] init];
	NSMutableArray *endTwitterersMutableArray = [[NSMutableArray alloc] initWithArray:endTwitterers];
	
	EPTwittererChain *nextChain = [tweetChainQueue popObject];
	[statusDelegate addStatusLine:[NSString stringWithFormat:@"Testing chain: %@",[nextChain description]]];
	
	while (! [self checkForEndTwitterersOneChainDeeperUsingInitialPath:nextChain
													   tweetChainQueue:tweetChainQueue
														 endTwitterers:&endTwitterersMutableArray
															 excluding:twitterersToExclude
													winningChainsArray:&theWinningChains
														  mapHintStore:mapHintStore]) {
		if ([tweetChainQueue count] == 0) break;
		
		nextChain = [tweetChainQueue popObject];
		[statusDelegate addStatusLine:[NSString stringWithFormat:@"Testing chain: %@",[nextChain description]]];
	}
	
	[endTwitterersMutableArray release];
	
	
	// if the queue ever ends up being empty (because any initial path already contains any possible
	// new followers in the chain), theWinningChain remains nil, and this method will return nil,
	// indicating that there's no winning chain
	
	return [theWinningChains autorelease];
}


- (BOOL)checkForEndTwitterersOneChainDeeperUsingInitialPath:(EPTwittererChain *)initialTweetChain
											tweetChainQueue:(CPriorityQueue *)tweetChainQueue
											  endTwitterers:(NSMutableArray **)endTwitterers
												  excluding:(NSArray *)twitterersToExclude
										 winningChainsArray:(NSMutableArray **)winningChainsArrayRef
											   mapHintStore:(EPTwittererMapHintStore **)mapHintStore;
{	
	// this pool is placed here because otherwise NSXMLDocuments from within getFriendsForTwitterer:
	// apparently don't get autoreleased as they should, causing the app to use up memory like nobody's
	// business; the friendsArray is retained and then autoreleased this way so that it makes the 
	// NSAutoreleasePool code here simpler, due to this function returning in multiple spots
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	EPFriendAndFollowerGetter *friendAndFollowerGetterInstance = [[EPFriendAndFollowerGetter alloc] initWithStatusDelegate:self
																										 andOperationQueue:theMainOperationQueue];
	NSArray *friendsArray = [friendAndFollowerGetterInstance getFriendsForTwitterer:[initialTweetChain lastTwittererInChain]];
	[friendAndFollowerGetterInstance release];

	NSString *startTwitterer = [initialTweetChain firstTwittererInChain];
	[friendsArray retain];
	[pool release];
	[friendsArray autorelease];
	
	
	NSString *nextFriend = nil;

	for (nextFriend in friendsArray) {
		if ([initialTweetChain containsTwitterer:nextFriend]) {
			// it already contains this twitterer, so we don't want to add any chains with
			// a duplicate twitterer in it
		} else {
			EPTwittererChain *newTweetChain = [[EPTwittererChain alloc] initWithInitialTweetChain:initialTweetChain];
			[newTweetChain addTwittererToChain:nextFriend];
			
			BOOL shouldAttemptShortCircuit = NO;
			if ([(*endTwitterers) containsObject:nextFriend]) {
				shouldAttemptShortCircuit = YES;
				
				// we've found a shortest chain!  Yay!

				[statusDelegate addStatusLine:[NSString stringWithFormat:@"Found winning chain: %@",[newTweetChain description]]];
				if (mapHintStore) [(*mapHintStore) addAllPartialPathsToEndTwittererOfChain:newTweetChain];
				if (mapHintStore) NSLog(@"%@",[(*mapHintStore) description]);
				
				[(*winningChainsArrayRef) addObject:[newTweetChain autorelease]];
				[(*endTwitterers) removeObject:nextFriend];
				
				if ( [(*endTwitterers) count] == 0) {
					// we've found *all* the shortest chains!  Woohoo!
					
					[newTweetChain release];
					return YES;
				}
			} else if ([twitterersToExclude containsObject:nextFriend]) {
				// we don't want to add this friend to any twitterer chain, so we do nothing
			} else if ([pastTwitterersArray containsObject:nextFriend] && (! [nextFriend isEqualToString:startTwitterer]) ) {
				// this is an optimization to the routine that finds the shortest path: if we've already
				// encountered a certain twitterer before, then it's already in some partial twitter chain
				// in the queue, and there's no reason to add this twitterer to another chain in the queue
				// because all subsequent chains will be the same after this twitterer
				
				// do nothing in this block
				
				// we also exclude the start twitterer in case the user is looking for a loop
				// from a twitterer to themselves
				
				//[self addStringToInAppErrorConsole:[NSString stringWithFormat:
												//	@"Skipped over @%@: already in another twitter chain.\n",nextFriend]];
			} else {
				shouldAttemptShortCircuit = YES;
				// we still want to add this chain to the queue and continue searching,
				// even if we used some partial paths in the map hint store to gain
				// full winning chains
				[tweetChainQueue addObject:newTweetChain];
				
				[pastTwitterersArray addObject:nextFriend];
				
				// fetch the file in the background, 'cause we don't need it right now
				EPXMLDownloadOperation *downloadOperation = [[EPXMLDownloadOperation alloc] initWithStatusDelegate:self];
				[downloadOperation setTwitterHandle:nextFriend];
				[theMainOperationQueue addOperation:downloadOperation];
				[downloadOperation release];
			}
			
			if (shouldAttemptShortCircuit) {
				// now let's check to see if there's a known partial chain
				// from the current friend to any of the end twitterers
				
				// note: this short-circuiting will still not produce chain loops;
				// for example, let's say I have a partial path @twit1 --> @twit2
				// --> @twit3, and I have a partial path @twit3 --> @twit2 --> @twit4,
				// we won't get @twit1 --> @twit2 --> @twit3 --> @twit2 -->@twit4,
				// because the priority queue would ensure that @twit1 --> @twit2 -->
				// @twit4 would have been found first
				
				// we don't need to worry about short-circuit partial chains including
				// explicit twitterers to exclude, because they never would have been
				// added to the store in the first place, because nothing is done
				// when we encounter an explicit twitterer to exclude
				
				NSString *nextEndTwitterer = nil;
				
				// exceptions will be raised about the array being mutated while being enumerated
				// if (*endTwitterers) is not copied to a new array
				if (mapHintStore) {
					
					for (nextEndTwitterer in [NSArray arrayWithArray:(*endTwitterers)] ) {
						EPTwittererChain *knownPartialChain = 
						[(*mapHintStore) knownPathExistsFromTwitterer:nextFriend toTwitterer:nextEndTwitterer];
						
						if (knownPartialChain) {
							// we've found a shortest chain!
							EPTwittererChain *aWinningChain = [[EPTwittererChain alloc] initWithInitialTweetChain:newTweetChain];
							[aWinningChain addPartialChainToChain:knownPartialChain];
							
							[statusDelegate addStatusLine:
							 [NSString stringWithFormat:@"Short-circuited to find winning chain: %@\n",[aWinningChain description]]];
							
							[(*mapHintStore) addAllPartialPathsToEndTwittererOfChain:aWinningChain];
							NSLog(@"%@",[(*mapHintStore) description]);
							[(*winningChainsArrayRef) addObject:[aWinningChain autorelease]];
							[(*endTwitterers) removeObject:nextEndTwitterer];
							
							if ( [(*endTwitterers) count] == 0) {
								// we've found *all* the shortest chains! Woohoo!
								
								[newTweetChain release];
								return YES;
							}
						}
					}
				}
			}
			
			[newTweetChain release];
		}
	}
	
	return NO;
}

- (NSArray *)validateTwitterNames:(NSArray *)twitterersToValidate;
{
	NSMutableArray *validatedTwittererNames = [[NSMutableArray alloc] init];
	NSString *nextTwitterer;
	
	for (nextTwitterer in twitterersToValidate) {
		// fetch the friends file for the twitterer
		/*EPXMLDownloadOperation *downloadOperation = [[EPXMLDownloadOperation alloc] initWithStatusDelegate:self];
		 [downloadOperation setTwitterHandle:nextTwitterer];
		 [theMainOperationQueue addOperation:downloadOperation];
		 [downloadOperation release];*/
		if (! [nextTwitterer isEqualToString:@""]) {
			NSString *correctedTwittererName = [self validateTwitterName:nextTwitterer];
			if (correctedTwittererName != nil) {
				[validatedTwittererNames addObject:correctedTwittererName];
			}
		}
	}
	
	return [validatedTwittererNames autorelease];
}

- (NSString *)validateTwitterName:(NSString *)twitterHandle;
{
	NSString *validatedTwitterName = nil;
	NSError *XMLDocError = nil;
	
	NSXMLDocument *userTimelineXMLDoc = nil;
	if (TURN_ON_HTML_SCRAPING) {
		userTimelineXMLDoc = [[NSXMLDocument alloc] initWithContentsOfURL:[NSURL URLWithString:
																						  [[NSString stringWithFormat:@"http://twitter.com/%@",twitterHandle]
																						   stringByExpandingTildeInPath]]
																				 options:NSXMLDocumentTidyHTML
																				   error:&XMLDocError];
		
		// NSXMLDocument gives errors for warnings after converting to XHTML, so we
		// don't want to stop here if there are errors, because the URL could still
		// have been loaded correctly
		
		NSError *xPathError = nil;
		NSArray *h2Array = [userTimelineXMLDoc nodesForXPath:@"//h2[@class='thumb clearfix']" error:&xPathError];
		if (xPathError) NSLog(@"%@",xPathError);
		
		xPathError = nil;
		NSArray *aArray = [[h2Array objectAtIndex:0] nodesForXPath:@".//a" error:&xPathError];
		NSXMLElement *aTag = (NSXMLElement *)[aArray objectAtIndex:0];
		
		
		/*NSXMLElement *htmlTag = (NSXMLElement *)[userTimelineXMLDoc childAtIndex:0];
		NSXMLElement *bodyTag = (NSXMLElement *)[htmlTag childAtIndex:1];
		NSXMLElement *divContainerTag = (NSXMLElement *)[bodyTag childAtIndex:2];
		NSXMLElement *tableTag = (NSXMLElement *)[divContainerTag childAtIndex:7];
		NSXMLElement *tbodyTag = (NSXMLElement *)[tableTag childAtIndex:1]; // this should be the first child tag, but isn't
		NSXMLElement *trTag = (NSXMLElement *)[tbodyTag childAtIndex:0];
		NSXMLElement *tdTag = (NSXMLElement *)[trTag childAtIndex:0];
		NSXMLElement *divWrapperTag = (NSXMLElement *)[tdTag childAtIndex:0];
		NSXMLElement *divProfileHeadTag = (NSXMLElement *)[divWrapperTag childAtIndex:0];
		NSXMLElement *h2Tag = (NSXMLElement *)[divProfileHeadTag childAtIndex:0];
		NSXMLElement *aTag = (NSXMLElement *)[h2Tag childAtIndex:0];*/

		
		NSString *theHref = [[aTag attributeForName:@"href"] stringValue]; 
		validatedTwitterName = [theHref lastPathComponent];
	} else {
		userTimelineXMLDoc = [[NSXMLDocument alloc] initWithContentsOfURL:[NSURL URLWithString:
																						  [[NSString stringWithFormat:@"http://twitter.com/statuses/user_timeline/%@.xml",twitterHandle]
																						   stringByExpandingTildeInPath]]
																				 options:NSXMLDocumentTidyXML
																				   error:&XMLDocError];
		
		if (XMLDocError) {
			[statusDelegate addStatusLine:[NSString stringWithFormat:@"%@",[XMLDocError localizedDescription]]];
			
			// validatedTwitterName will be nil at the end of this method if there's an error with loading the XML file
		} else {
			validatedTwitterName = [[[[[userTimelineXMLDoc childAtIndex:0] childAtIndex:0] childAtIndex:8] childAtIndex:2] stringValue];
		}
	}
	
	[userTimelineXMLDoc setChildren:nil];
	[userTimelineXMLDoc release];
	return validatedTwitterName;
}

@end
