//
//  CHeap.m
//  OperationQueue
//
//  Created by Jonathan Wight on 3/13/07.
//  Copyright 2007 Toxic Software. All rights reserved.
//

#import "CHeap.h"

#include <algorithm>
#include <vector>
#include <deque>
#include <functional>
#include <queue>

#include "CCocoaObject.h"

struct selector_compare : public std::binary_function<CCocoaObject, CCocoaObject, bool> {
		CHeap *heap;

		selector_compare(CHeap *inHeap)
			:	heap(inHeap)
			{
			}
		bool operator()(CCocoaObject &inLHS, CCocoaObject &inRHS)
			{
			ComparisonFunctionPtr theFunction = [heap comparisonFunction];
			if (theFunction)
				{
				void *theUserData = [heap comparisonUserData];
				return theFunction(inLHS.object(), inRHS.object(), theUserData) == NSOrderedAscending;
				}
			else
				{
				return([inLHS.object() compare:inRHS.object()] == NSOrderedAscending);
				}
			}
    };


typedef std::deque <CCocoaObject> TObjectHeap;

#pragma mark -

@interface CHeapEnumerator : NSEnumerator {
	CHeap *heap;
};

- (id)initWithHeap:(CHeap *)inHeap;

@end

#pragma mark -

@implementation CHeap

- (id)init
{
if ((self = [super init]) != NULL)
	{
	implementation = new TObjectHeap();
	}
return(self);
}

- (id)initWithArray:(NSArray *)inArray
{
if ((self = [self init]) != NULL)
	{
	// TODO We could just populate the deque and then rebuild it (more efficient, especially for larger arrays).
	NSEnumerator *theEnumerator = [inArray objectEnumerator];
	id theObject = NULL;
	while ((theObject = [theEnumerator nextObject]) != NULL)
		{
		[self pushObject:theObject];
		}
	}
return(self);
}

- (void)dealloc
{
delete (TObjectHeap *)implementation;
implementation = NULL;
//
[super dealloc];
}

- (ComparisonFunctionPtr)comparisonFunction
{
return(comparisonFunction);
}

- (void)setComparisonFunction:(ComparisonFunctionPtr)inComparisonFunction
{
comparisonFunction = inComparisonFunction;
}

- (void *)comparisonUserData
{
return(comparisonUserData);
}

- (void)setComparisonUserData:(void *)inComparisonUserData
{
comparisonUserData = inComparisonUserData;
}

- (unsigned)count
{
TObjectHeap &theHeap = *(TObjectHeap *)implementation;
return(theHeap.size());
}

- (void)pushObject:(id)inObject
{
TObjectHeap &theHeap = *(TObjectHeap *)implementation;

[inObject retain];
theHeap.push_back(inObject);

std::push_heap(theHeap.begin(), theHeap.end(), selector_compare(self));
}

- (id)popObject
{
TObjectHeap &theHeap = *(TObjectHeap *)implementation;

if (theHeap.size() == 0)
	{
	return(NULL);
	}

std::pop_heap(theHeap.begin(), theHeap.end(), selector_compare(self));

id theObject = (theHeap.end() - 1)->object();
[theObject autorelease];

theHeap.pop_back();

return(theObject);
}

- (id)topObject
{
TObjectHeap &theHeap = *(TObjectHeap *)implementation;
if (theHeap.size() == 0)
	return(NULL);
else
	{
	id theObject = (theHeap.begin())->object();
	return(theObject);
	}
}

- (BOOL)containsObject:(id)inObject
{
TObjectHeap &theHeap = *(TObjectHeap *)implementation;
return(std::find(theHeap.begin(), theHeap.end(), inObject) != theHeap.end());
}

- (void)addObject:(id)inObject;
{
[self pushObject:inObject];
}

- (void)removeObject:(id)inObject
{
TObjectHeap &theHeap = *(TObjectHeap *)implementation;

TObjectHeap::iterator X = std::find(theHeap.begin(), theHeap.end(), inObject);
if (X != theHeap.end())
	{
	theHeap.erase(X);
	[self rebuild];
	}
}

- (NSArray *)allObjects
{
TObjectHeap &theHeap = *(TObjectHeap *)implementation;
NSMutableArray *theObjects = [[[NSMutableArray alloc] initWithCapacity:theHeap.size()] autorelease];
for (TObjectHeap::iterator X = theHeap.begin(); X != theHeap.end(); ++X)
	{
	[theObjects addObject:X->object()];
	}
return([[theObjects copy] autorelease]);
}

- (NSEnumerator *)objectEnumerator
{
// TODO Obviously this is grossly inefficient.
return([[self allObjects] objectEnumerator]);
}

- (NSEnumerator *)poppingEnumerator
{
return([[[CHeapEnumerator alloc] initWithHeap:self] autorelease]);
}

- (void)rebuild
{
TObjectHeap &theHeap = *(TObjectHeap *)implementation;

std::make_heap(theHeap.begin(), theHeap.end(), selector_compare(self));
}

@end

#pragma mark -

@implementation CHeapEnumerator

- (id)initWithHeap:(CHeap *)inHeap
{
if ((self = [super init]) != NULL)
	{
	heap = [inHeap retain];
	}
return(self);
}

- (void)dealloc
{
[heap autorelease];
heap = NULL;
//
[super dealloc];
}

- (id)nextObject
{
return([heap popObject]);
}

@end