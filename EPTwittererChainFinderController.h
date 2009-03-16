//
//  EPTwittererChainFinderController.h
//  Degrees of Tweetdom
//
//  Created by Simone Manganelli on 2008-08-24.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class EPTwittererChainFinder;


@interface EPTwittererChainFinderController : NSWindowController {
	IBOutlet NSTextView *errorConsoleView;
	IBOutlet NSTextField *statusTextField;
	IBOutlet NSTextField *firstTwittererTextField;
	IBOutlet NSTextField *secondTwittererTextField;
	
	EPTwittererChainFinder *twittererChainFinderInstance;
}

- (void)addStatusLine:(NSString *)statusLine;
- (void)scrollErrorConsoleToBottom;

- (IBAction)startChainSearch:(id)sender;

@end
