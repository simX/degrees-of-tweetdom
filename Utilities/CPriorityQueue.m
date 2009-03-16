//
//  CPriorityQueue.m
//  OperationQueue
//
//  Created by Jonathan Wight on 4/14/07.
//  Copyright 2007 Toxic Software. All rights reserved.
//

#import "CPriorityQueue.h"

#import "CHeap.h"

static NSComparisonResult MyComparison(id inLHS, id inRHS, void *inData);

@implementation CPriorityQueue

- (id)init
{
if ((self = [super init]) != NULL)
	{
	heap = [[CHeap alloc] init];
	[heap setComparisonFunction:MyComparison];
	//
	objects = [[NSMutableDictionary alloc] init];
	[self setPriorityKey:@"self"];
	}
return(self);
}

- (void)dealloc
{
[heap autorelease];
heap = NULL;
[objects autorelease];
objects = NULL;
[self setPriorityKey:NULL];
//
[super dealloc];
}

- (NSString *)priorityKey
{
return(priorityKey); 
}

- (void)setPriorityKey:(NSString *)inPriorityKey
{
if (priorityKey != inPriorityKey)
    {
	[priorityKey autorelease];
	priorityKey = [inPriorityKey retain];
    }
}

- (unsigned)count
{
return([objects count]);
}

- (void)pushObject:(id)inObject
{
NSAssert(inObject != NULL, @"inObject != NULL");
id thePriority = [inObject valueForKey:priorityKey];
NSAssert(thePriority != NULL, @"thePriority != NULL");
if ([heap containsObject:thePriority] == NO)
	[heap pushObject:thePriority];

NSMutableArray *theObjectsForPriority = [objects objectForKey:thePriority];
if (theObjectsForPriority == NULL)
	{
	theObjectsForPriority = [NSMutableArray arrayWithObject:inObject];
	[objects setObject:theObjectsForPriority forKey:thePriority];
	}
else
	{
	[theObjectsForPriority addObject:inObject];
	}
}

- (id)popObject
{
id thePriority = [heap topObject];
NSAssert(thePriority != NULL, @"thePriority != NULL");
NSMutableArray *theObjectsForPriority = [objects objectForKey:thePriority];
id theObject = [[theObjectsForPriority objectAtIndex:0] retain];
[theObjectsForPriority removeObjectAtIndex:0];
// Clean up heap and objects
if ([theObjectsForPriority count] == 0)
	{
	[heap removeObject:thePriority];
	
	[objects removeObjectForKey:thePriority];
	}

return([theObject autorelease]);
}

- (BOOL)containsObject:(id)inObject
{
id thePriority = [inObject valueForKey:priorityKey];
NSMutableArray *theObjectsForPriority = [objects objectForKey:thePriority];
return([theObjectsForPriority containsObject:inObject]);
}

- (void)addObject:(id)inObject
{
[self pushObject:inObject];
}

- (void)removeObject:(id)inObject
{
id thePriority = [inObject valueForKey:priorityKey];
NSMutableArray *theObjectsForPriority = [objects objectForKey:thePriority];
[theObjectsForPriority removeObject:inObject];
// Clean up heap and objects
if ([theObjectsForPriority count] == 0)
	{
	[heap popObject];
	[objects removeObjectForKey:thePriority];
	}
}

- (NSArray *)allObjects
{
NSMutableArray *theObjects = [NSMutableArray array];
NSEnumerator *theEnumerator = [objects objectEnumerator];
NSArray *theObjectsForPriority = NULL;
while ((theObjectsForPriority = [theEnumerator nextObject]) != NULL)
	{
	[theObjects addObject:theObjectsForPriority];
	}
return(theObjects);
}

- (NSEnumerator *)objectEnumerator
{
// TODO Obviously this is grossly inefficient.
return([[self allObjects] objectEnumerator]);
}

@end

static NSComparisonResult MyComparison(id inLHS, id inRHS, void *inData)
{
#pragma unused (inData)

return([inLHS compare:inRHS]);
}
