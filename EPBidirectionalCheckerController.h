//
//  EPBidirectionalCheckerController.h
//  Degrees of Tweetdom
//
//  Created by Simone Manganelli on 2008-08-22.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class EPBidirectionalChecker;


@interface EPBidirectionalCheckerController : NSWindowController {
	IBOutlet NSTextField *twittererHandleTextField;
	IBOutlet NSSecureTextField *twittererPasswordTextField;
	IBOutlet NSTextView *statsTextView;
	
	EPBidirectionalChecker *bidirectionalCheckerInstance;
}

- (void)addStatusLine:(NSString *)statusLine;
- (void)scrollErrorConsoleToBottom;

- (IBAction)startBidirectionalStatsRetrieval:(id)sender;
- (void)retrieveBidirectionalStats;

@end
