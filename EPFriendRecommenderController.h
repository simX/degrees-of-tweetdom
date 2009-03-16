//
//  EPFriendRecommenderController.h
//  Degrees of Tweetdom
//
//  Created by Simone Manganelli on 2008-08-26.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class EPFriendRecommender;


@interface EPFriendRecommenderController : NSWindowController {
	IBOutlet NSTextField *twittererTextField;
	IBOutlet NSTextField *levelsDeepTextField;
	IBOutlet NSTextView *statusConsoleView;
	
	EPFriendRecommender *friendRecommenderInstance;
}

- (void)addStatusLine:(NSString *)statusLine;
- (void)scrollErrorConsoleToBottom;

- (IBAction)startFriendRecommending:(id)sender;

@end
