//
//  EPTwittererMapper.h
//  Degrees of Tweetdom
//
//  Created by Simone Manganelli on 2008-04-19.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class EPTwittererChainFinder;
@class EPTwittererMapHintStore;


@interface EPTwittererMapper : NSObject {
	id statusDelegate;
}

- (id)initWithStatusDelegate:(id)delegate;
- (void)addStatusLine:(NSString *)statusLine;

- (NSImage *)createMapOfTwitterers:(NSArray *)arrayOfTwitterers
						 excluding:(NSArray *)twitterersToExclude;

@end
