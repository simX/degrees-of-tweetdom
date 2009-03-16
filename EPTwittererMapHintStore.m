//
//  EPTwittererMapHintStore.m
//  Degrees of Tweetdom
//
//  Created by Simone Manganelli on 2008-04-24.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "EPTwittererMapHintStore.h"
#import "EPTwittererChain.h"


@implementation EPTwittererMapHintStore

- (id)init;
{
	if (self = [super init]) {
		twitterMapHintsDict = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}


- (void)dealloc;
{
	[twitterMapHintsDict release];
	[super dealloc];
}


- (NSString *)description;
{
	return [twitterMapHintsDict description];
}


// this method will return a partial twitter chain if there's already a known path between
// the start twitterer and the end twitterer, and nil if there isn't a known partial chain
- (EPTwittererChain *)knownPathExistsFromTwitterer:(NSString *)startTwitterer toTwitterer:(NSString *)endTwitterer;
{
	NSDictionary *specificTwitterHintsDict = [twitterMapHintsDict objectForKey:endTwitterer];
	
	EPTwittererChain *knownPartialChain = nil;
	if (specificTwitterHintsDict) {
		// knownPartialChain will be nil if there is no known
		// partial path, which is perfect
		knownPartialChain = [specificTwitterHintsDict objectForKey:startTwitterer];
	}
	
	return knownPartialChain;
}


- (void)addKnownPathBetweenTwitterers:(EPTwittererChain *)partialTwitterChain;
{
	NSMutableDictionary *specificTwittererHintsDict = [twitterMapHintsDict objectForKey:[partialTwitterChain lastTwittererInChain]];
	
	if (specificTwittererHintsDict) {
		EPTwittererChain *existingPartialChain = [specificTwittererHintsDict objectForKey:[partialTwitterChain firstTwittererInChain]];
		
		if (existingPartialChain) {
			// there's already a known partial path between these two twitterers;
			// so we do nothing
			
			// something to think about: if there already exists a known partial
			// path, is it guaranteed to be the shortest?
		} else {
			[specificTwittererHintsDict setObject:partialTwitterChain forKey:[partialTwitterChain firstTwittererInChain]];
		}
	} else {
		NSMutableDictionary *newSpecificTwittererHintsDict = [[NSMutableDictionary alloc] init];
		[newSpecificTwittererHintsDict setObject:partialTwitterChain forKey:[partialTwitterChain firstTwittererInChain]];
		[newSpecificTwittererHintsDict release];
		 
		[twitterMapHintsDict setObject:newSpecificTwittererHintsDict forKey:[partialTwitterChain lastTwittererInChain]];
	}
}

- (void)addAllPartialPathsToEndTwittererOfChain:(EPTwittererChain *)twitterChain;
{
	int i;
	NSArray *chainStepsArray = [twitterChain chainStepsArray];
	
	for (i = 0; i < [chainStepsArray count] - 1; i++) {
		EPTwittererChain *newChain = [[EPTwittererChain alloc] initWithInitialChainStepsArray:
									  [chainStepsArray subarrayWithRange:NSMakeRange(i,[chainStepsArray count] - i)]];
		[self addKnownPathBetweenTwitterers:newChain];
		[newChain release];
	}
}

@end
