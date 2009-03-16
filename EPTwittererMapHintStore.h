//
//  EPTwittererMapHintStore.h
//  Degrees of Tweetdom
//
//  Created by Simone Manganelli on 2008-04-24.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class EPTwittererChain;


@interface EPTwittererMapHintStore : NSObject {
	NSMutableDictionary *twitterMapHintsDict;
}

- (EPTwittererChain *)knownPathExistsFromTwitterer:(NSString *)startTwitterer toTwitterer:(NSString *)endTwitterer;
- (void)addKnownPathBetweenTwitterers:(EPTwittererChain *)partialTwitterChain;
- (void)addAllPartialPathsToEndTwittererOfChain:(EPTwittererChain *)twitterChain;

@end
