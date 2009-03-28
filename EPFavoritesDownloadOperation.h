//
//  EPFavoritesDownloadOperation.h
//  Degrees of Tweetdom
//
//  Created by Simone Manganelli on 3/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface EPFavoritesDownloadOperation : NSOperation {
	NSString *twitterHandle;
	id statusDelegate;
}

- (id)initWithStatusDelegate:(id)delegate;
- (void)setTwitterHandle:(NSString *)newTwitterHandle;

@end
