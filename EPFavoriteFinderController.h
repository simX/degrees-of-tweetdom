//
//  EPFavoriteFinderController.h
//  Degrees of Tweetdom
//
//  Created by Simone Manganelli on 3/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class EPFavoriteFinder;

@interface EPFavoriteFinderController : NSWindowController {
	EPFavoriteFinder *favoriteFinderInstance;
	
	IBOutlet NSTextField *twittererTextField;
	IBOutlet NSTextView *resultsView;
}

- (void)findAuthoredFavorites;
- (void)addStatusLine:(NSString *)statusLine;
- (IBAction)startAuthoredFavoritesRetrieval:(id)sender;

int favoritersSortDescending(id firstFav, id secondFav, void *context);

@end
