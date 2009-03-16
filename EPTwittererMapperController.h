//
//  EPTwittererMapperController.h
//  Degrees of Tweetdom
//
//  Created by Simone Manganelli on 2008-08-26.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class EPTwittererMapper;


@interface EPTwittererMapperController : NSWindowController {
	IBOutlet NSTextView *errorConsoleView;
	
	IBOutlet NSTextField *twitterersToMapTextField;
	IBOutlet NSTextField *twitterersToExcludeTextField;
	
	IBOutlet NSImageView *mapImageView;
	
	EPTwittererMapper *twittererMapperInstance;
}

- (void)addStatusLine:(NSString *)statusLine;
- (void)scrollErrorConsoleToBottom;

- (IBAction)startTwitterMapping:(id)sender;

@end
