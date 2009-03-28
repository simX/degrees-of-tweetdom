//
//  EPTwittererMapper.m
//  Degrees of Tweetdom
//
//  Created by Simone Manganelli on 2008-04-19.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "EPTwittererMapper.h"
#import "EPTwittererChainFinder.h"
#import "EPTwittererChain.h"
#import "EPTwittererMapHintStore.h"


@implementation EPTwittererMapper


- (id)initWithStatusDelegate:(id)delegate;
{
	statusDelegate = delegate;
	
	return [self init];
}

- (void)addStatusLine:(NSString *)statusLine;
{
	[statusDelegate addStatusLine:statusLine];
}

- (NSImage *)createMapOfTwitterers:(NSArray *)arrayOfTwitterers
						 excluding:(NSArray *)twitterersToExclude;
{
	EPTwittererChainFinder *twittererChainFinder = [[EPTwittererChainFinder alloc] initWithStatusDelegate:self];
	
	NSArray *validatedTwittererArray = [twittererChainFinder validateTwitterNames:arrayOfTwitterers];
	NSArray *validatedExclusions = [twittererChainFinder validateTwitterNames:twitterersToExclude];
	
	NSMutableArray *arrayOfWinningChains = [[NSMutableArray alloc] init];
	EPTwittererMapHintStore *theMapHintStore = [[EPTwittererMapHintStore alloc] init];
	
	NSString *twittererOne = nil;
	for (twittererOne in validatedTwittererArray) {
		NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:validatedTwittererArray];
		[tempArray removeObject:twittererOne];
		
		[statusDelegate addStatusLine:[NSString stringWithFormat:@"Searching for chains from %@\n",twittererOne]];
		NSLog(@"%@",[theMapHintStore description]);
		NSArray *someWinningChains = [twittererChainFinder findShortestPathFrom:twittererOne
																			 to:tempArray 
																	  excluding:validatedExclusions
															  usingMapHintStore:&theMapHintStore];
		[someWinningChains retain];
		[arrayOfWinningChains addObjectsFromArray:someWinningChains];
		[someWinningChains release];
		[tempArray release];
	}
	
	[theMapHintStore release];
	
	NSMutableArray *arrayOfMapChainSteps = [[NSMutableArray alloc] init];
	NSMutableArray *arrayOfTwitterersOnMap = [[NSMutableArray alloc] init];
	
	EPTwittererChain *nextChain = nil;
	for (nextChain in arrayOfWinningChains) {
		int i;
		NSArray *twitterersInChain = [nextChain chainStepsArray];
		for (i=0; i < [twitterersInChain count]; i++) {
			if (! [arrayOfTwitterersOnMap containsObject:[twitterersInChain objectAtIndex:i]]) {
				[arrayOfTwitterersOnMap addObject:[twitterersInChain objectAtIndex:i]];
			}
			
			if (i <= [twitterersInChain count] - 2) {
				NSString *chainStep = [NSString stringWithFormat:@"%@ -> %@;",
									   [twitterersInChain objectAtIndex:i],
									   [twitterersInChain objectAtIndex:i+1]];
				
				if (! [arrayOfMapChainSteps containsObject:chainStep]) [arrayOfMapChainSteps addObject:chainStep];
			}
		}
	}
	
	NSLog(@"Chain steps on map: %@\nTwitterers on map: %@",arrayOfMapChainSteps, arrayOfTwitterersOnMap);

	
	// we need to download the profile images for each twitterer
	
	[statusDelegate addStatusLine:@"Downloading profile images and writing graphviz file...\n"];
	
	
	NSMutableString *graphvizFileString = [[NSMutableString alloc] init];
		// add in \t\tsize=\"5,5\";\n
	[graphvizFileString appendString:@"digraph untitled\n\t{\n\t\tfontname=\"MyriadApple-Bold\";\n\t\tfontsize=\"20\";\n\t\tnode [fontname=\"MyriadApple-Bold\", fontsize=\"20\"];\n\t\tnodesep = 0.15;\n\t\tranksep = 0.05;\n\n"];
	
	NSString *nextTwitterer = nil;
	for (nextTwitterer in arrayOfTwitterersOnMap) {
		[graphvizFileString appendString:[NSString stringWithFormat:@"\t\t%@ [label=\"\", shapefile=\"%@.png\"];\n",nextTwitterer,nextTwitterer]];
	}
	
	[graphvizFileString appendString:@"\n"];
	
	NSString *nextChainStep = nil;
	for (nextChainStep in arrayOfMapChainSteps) {
		[graphvizFileString appendString:[NSString stringWithFormat:@"\t\t%@\n",nextChainStep]];
	}
	
	[graphvizFileString appendString:@"\t}"];
	
	NSError *fileWriteError = nil;
	[graphvizFileString writeToFile:[@"~/Library/Caches/Degrees of Tweetdom/twitterer-map.dot" stringByExpandingTildeInPath]
						 atomically:YES
						   encoding:NSUTF8StringEncoding
							  error:&fileWriteError];
	
	[graphvizFileString release];
	
	if (fileWriteError) [statusDelegate addStatusLine:[fileWriteError localizedDescription]];
	[arrayOfWinningChains release];
	
	
	for (nextTwitterer in arrayOfTwitterersOnMap) {
		// this can result in an error if the user's timeline is protected
		NSXMLDocument *twittererTimelineXMLDoc = [[NSXMLDocument alloc] initWithContentsOfURL:[NSURL URLWithString:
																							   [NSString stringWithFormat:@"http://twitter.com/statuses/user_timeline/%@.xml",nextTwitterer]]
																					  options:NSXMLDocumentTidyXML
																						error:nil];
		
		
		if (! [[[[twittererTimelineXMLDoc childAtIndex:0] childAtIndex:0] name] isEqualToString:@"error"]) {
			NSError *xPathError = nil;
			NSArray *profileImageURLNodeArray = [twittererTimelineXMLDoc nodesForXPath:@".//profile_image_url" error:&xPathError];
			NSString *profileImageURLString = [(NSXMLElement *)[profileImageURLNodeArray objectAtIndex:0] stringValue];
			NSURL *profileImageURL = [NSURL URLWithString:profileImageURLString];
			//NSURL *profileImageURL = [NSURL URLWithString:
			//						  [[[[[twittererTimelineXMLDoc childAtIndex:0] childAtIndex:0] childAtIndex:8] childAtIndex:5] stringValue]];
			
			[self writeProfileImageOfTwitterer:nextTwitterer toDiskUsingProfileImageURL:profileImageURL];
		} else {
			// there's an error; this happens if the updates are protected
			
			// this can be worked around here by getting the HTML file at twitter.com/twitterHandle and scraping
			// the HTML for the user's avatar
		}
		
		[twittererTimelineXMLDoc release];
	}
	
	[statusDelegate addStatusLine:@"Twitter map resources written to ~/Library/Caches/Degrees of Tweetdom/\n"];
	[statusDelegate addStatusLine:@"Creating twitter map image...\n"];
	
	NSTask *theTask = [[NSTask alloc] init];
	[theTask setLaunchPath:@"/opt/local/bin/dot"];
	[theTask setArguments:[NSArray arrayWithObjects:@"-Tpng",@"-otwitterer-map.png",@"twitterer-map.dot",nil]];
	[theTask setCurrentDirectoryPath:[@"~/Library/Caches/Degrees of Tweetdom/" stringByExpandingTildeInPath]];
	[theTask launch];
	
	while ([theTask isRunning]) {
		sleep(1);
	}
	
	[theTask release];
	[statusDelegate addStatusLine:@"Done creating Twitterer map.\n"];
	
	NSImage *theMapImage = [[NSImage alloc] initWithContentsOfFile:[@"~/Library/Caches/Degrees of Tweetdom/twitterer-map.png" stringByExpandingTildeInPath]];
	
	[arrayOfTwitterersOnMap release];
	[arrayOfMapChainSteps release];
	[twittererChainFinder release];
	
	return [theMapImage autorelease];	
}

- (void)writeProfileImageOfTwitterer:(NSString *)twittererHandle toDiskUsingProfileImageURL:(NSURL *)profileImageURL;
{
	NSImage *profileImage = [[NSImage alloc] initWithContentsOfURL:profileImageURL];
	if (! profileImage) {
		[profileImage release];
		profileImage = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://static.twitter.com/images/default_profile_bigger.png"]];
	}
	[profileImage setSize:NSMakeSize(48,48)];
	
	NSImage *profilePlusNameImage = [[NSImage alloc] initWithSize:NSMakeSize(70,70)];
	[profilePlusNameImage lockFocus];
	
	[profileImage drawInRect:NSMakeRect(11,22,48,48)
					fromRect:NSMakeRect(0,0,profileImage.size.width,profileImage.size.height)
				   operation:NSCompositeSourceOver
					fraction:1.0];
	
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys: 
									[NSFont systemFontOfSize:10],NSFontAttributeName,
									[NSColor blackColor], NSForegroundColorAttributeName,
									nil];
	NSSize stringSize = [twittererHandle sizeWithAttributes:attributes];
	int xOffset = (70 - stringSize.width)/2;
	int yOffset = (22 - stringSize.height)/2;
	[twittererHandle drawAtPoint:NSMakePoint(xOffset, yOffset) withAttributes:attributes]; 
	
	[profilePlusNameImage unlockFocus];
	
	NSData *tiffRep = [profilePlusNameImage TIFFRepresentation];
	[profilePlusNameImage release];
	[profileImage release];
	
	NSImage *newProfileImage = [[NSImage alloc] initWithData:tiffRep];
	NSData *profileImageData = [NSBitmapImageRep representationOfImageRepsInArray:[newProfileImage representations] usingType:NSPNGFileType properties:nil];
	
	[profileImageData
	 writeToFile:[[NSString stringWithFormat:@"~/Library/Caches/Degrees of Tweetdom/%@.png",twittererHandle] stringByExpandingTildeInPath]
	 atomically:YES];
	
	[newProfileImage release];
}

@end
