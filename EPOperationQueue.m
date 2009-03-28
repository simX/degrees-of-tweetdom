//
//  EPOperationQueue.m
//  Degrees of Tweetdom
//
//  Created by Simone Manganelli on 3/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "EPOperationQueue.h"


@implementation EPOperationQueue

- (id)init;
{
	if (self = [super init]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"operationQueueCreated" object:self];
	}
	
	return self;
}

- (void)dealloc;
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"operationQueueDeleted" object:self];
	
	[super dealloc];
}

@end
