//
//  EPTweetChain.h
//  Degrees of Tweetdom
//
//  Created by Simone Manganelli on 2008-04-09.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface EPTwittererChain : NSObject {
	int pathLength;
	NSMutableArray *chainStepsArray;
}

- (id)initWithInitialTweetChain:(EPTwittererChain *)initialChain;
- (id)initWithInitialChainStepsArray:(NSArray *)initialChainStepsArray;

- (void)setRootTwitterer:(NSString *)startTwitterer;
- (void)addTwittererToChain:(NSString *)twittererHandle;
- (void)addPartialChainToChain:(EPTwittererChain *)partialChain;

- (NSString *)lastTwittererInChain;
- (NSString *)firstTwittererInChain;
- (BOOL)containsTwitterer:(NSString *)twittererHandle;
- (int)pathLength;
- (NSArray *)chainStepsArray;

- (void)setPathLength:(int)newPathLength;

@end
