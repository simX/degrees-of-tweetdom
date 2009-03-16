//
//  EPAppController.h
//  Degrees of Tweetdom
//
//  Created by Simone Manganelli on 2008-08-22.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface EPAppController : NSObject {
	NSMutableArray *arrayOfOperationQueues;
	
	IBOutlet NSTextField *numberOfNSOperationsTextField;
	IBOutlet NSTextField *numberOfNSOperationQueuesTextField;
}

- (void)operationQueueCreatedNotification:(NSNotification *)notification;
- (void)operationQueueDeletedNotification:(NSNotification *)notification;
- (void)updateActivityWindowStats;

- (IBAction)createNewBidirectionalCheckerWindow:(id)sender;
- (IBAction)createNewTwittererChainFinderWindow:(id)sender;
- (IBAction)createNewFriendRecommenderWindow:(id)sender;
- (IBAction)createNewTwittererMapperWindow:(id)sender;

@end
