//
//  EPTweetChain.m
//  Degrees of Tweetdom
//
//  Created by Simone Manganelli on 2008-04-09.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "EPTwittererChain.h"


@implementation EPTwittererChain

- (id)init;
{
	if (self = [super init]) {
		chainStepsArray = [[NSMutableArray alloc] init];
		pathLength = 1;
	}
	
	return self;
}

- (void)dealloc;
{
	[chainStepsArray release];
	[super dealloc];
}

- (id)initWithInitialTweetChain:(EPTwittererChain *)initialChain;
{
	if (self = [super init]) {
		chainStepsArray = [[NSMutableArray alloc] initWithArray:[initialChain chainStepsArray]];
		pathLength = 1 - [chainStepsArray count];
	}
	
	return self;
}

- (id)initWithInitialChainStepsArray:(NSArray *)initialChainStepsArray;
{
	if (self = [super init]) {
		chainStepsArray = [initialChainStepsArray copy];
		pathLength = 1 - [chainStepsArray count];
	}
	
	return self;
}

- (NSString *)description;
{
	NSMutableString *descriptionString = [[NSMutableString alloc] init];
	NSString *nextTwitterer = nil;
	
	for (nextTwitterer in chainStepsArray) {
		[descriptionString appendString:[NSString stringWithFormat:@"%@ --> ",nextTwitterer]];
	}
	
	[descriptionString appendString:@"end."];
	return [descriptionString autorelease];
}

- (void)setRootTwitterer:(NSString *)startTwitterer;
{
	[chainStepsArray release];
	chainStepsArray = [[NSArray alloc] initWithObjects:startTwitterer,nil];
	pathLength = 0;
}


- (void)addTwittererToChain:(NSString *)twittererHandle;
{
	[chainStepsArray addObject:twittererHandle];
	pathLength--;
}


- (void)addPartialChainToChain:(EPTwittererChain *)partialChain;
{
	if ([[chainStepsArray lastObject] isEqualToString:[[partialChain chainStepsArray] objectAtIndex:0]]) {
		// the chain to add starts with the same twitterer as the current end twitterer,
		// so we don't want to end up with a twitterer being duplicated in the same chain
		
		[chainStepsArray addObjectsFromArray:[[partialChain chainStepsArray]
											  subarrayWithRange:NSMakeRange(1,[[partialChain chainStepsArray] count] - 1)]
		 ];
		pathLength -= ([[partialChain chainStepsArray] count] - 1);
	} else {
		[chainStepsArray addObjectsFromArray:[partialChain chainStepsArray]];
		pathLength -= [[partialChain chainStepsArray] count];
	}
}


- (NSString *)lastTwittererInChain;
{
	return [chainStepsArray lastObject];
}

- (NSString *)firstTwittererInChain;
{
	return [chainStepsArray objectAtIndex:0];
}


- (BOOL)containsTwitterer:(NSString *)twittererHandle;
{
	return [chainStepsArray containsObject:twittererHandle];
}


- (int)pathLength;
{
	return pathLength;
}
						   

- (NSArray *)chainStepsArray;
{
	return chainStepsArray;
}

// this should *never* be used except for testing purposes;
// add twitterers to the chain to increase the path length
- (void)setPathLength:(int)newPathLength;
{
	pathLength = newPathLength;
}

@end
