//
//  CThreadPool.m
//  OperationQueue
//
//  Created by Jonathan Wight on 3/13/07.
//  Copyright 2007 Toxic Software. All rights reserved.
//

#import "CThreadPool.h"

@implementation CThreadPool

- (id)init
{
if ((self = [super init]) != NULL)
	{
	desiredThreadCount = 0;
	currentThreadCount = [[NSConditionLock alloc] initWithCondition:0];
	threads = [[NSMutableArray alloc] init];
	}
return(self);
}

- (void)dealloc
{
[self setTarget:NULL];
[self setParameter:NULL];

[currentThreadCount release];
currentThreadCount = NULL;

[threads release];
threads = NULL;
//
[super dealloc];
}


- (SEL)selector
{
return selector;
}

- (void)setSelector:(SEL)inSelector
{
selector = inSelector;
}

- (id)target
{
return(target); 
}

- (void)setTarget:(id)inTarget
{
if (target != inTarget)
    {
	[target autorelease];
	target = [inTarget retain];
    }
}

- (id)parameter
{
return(parameter); 
}

- (void)setParameter:(id)inParameter
{
if (parameter != inParameter)
    {
	[parameter autorelease];
	parameter = [inParameter retain];
    }
}

- (int)desiredThreadCount
{
return(desiredThreadCount);
}

- (void)setDesiredThreadCount:(int)inDesiredThreadCount
{
if (inDesiredThreadCount != desiredThreadCount)
	{
	if (inDesiredThreadCount > desiredThreadCount)
		{
		desiredThreadCount = inDesiredThreadCount;
		int theCurrentThreadCount = [self currentThreadCount];

		for (int N = theCurrentThreadCount; N != inDesiredThreadCount; ++N)
			{
			[self detachNewThreadSelector:[self selector] toTarget:[self target] withObject:[self parameter]];
			}
		}
	else
		{
		desiredThreadCount = inDesiredThreadCount;
		}
	}
}

- (int)currentThreadCount
{
return([currentThreadCount condition]);
}

- (void)addThread:(NSThread *)inThread
{
if ([self currentThreadCount] >= [self desiredThreadCount])
	{
	[NSException raise:NSGenericException format:@"CThreadPool: Could not add another thread. I'm full!"];
	}

[self willChangeValueForKey:@"currentThreadCount"];
[currentThreadCount lock];
[threads addObject:inThread];
[currentThreadCount unlockWithCondition:[self currentThreadCount] + 1];
[self didChangeValueForKey:@"currentThreadCount"];
}

- (void)removeThread:(NSThread *)inThread
{
[self willChangeValueForKey:@"currentThreadCount"];
[currentThreadCount lock];
[threads removeObject:inThread];
[currentThreadCount unlockWithCondition:[self currentThreadCount] - 1];
[self didChangeValueForKey:@"currentThreadCount"];
}

- (void)waitUntilZeroThreads
{
int theDesiredThreadCount = [self desiredThreadCount];
[self setDesiredThreadCount:0];
[currentThreadCount lockWhenCondition:0];
[currentThreadCount unlock];
[self setDesiredThreadCount:theDesiredThreadCount];
}

- (void)detachNewThreadSelector:(SEL)inSelector toTarget:(id)inTarget withObject:(id)inArgument
{
NSMethodSignature *theMethodSignature = [inTarget methodSignatureForSelector:inSelector];
NSInvocation *theInvocation = [NSInvocation invocationWithMethodSignature:theMethodSignature];
[theInvocation setTarget:inTarget];
[theInvocation setSelector:inSelector];
[theInvocation setArgument:&inArgument atIndex:2];
[theInvocation retainArguments];

[NSThread detachNewThreadSelector:@selector(threadMain:) toTarget:self withObject:theInvocation];
}

#pragma mark -

- (void)threadMain:(NSInvocation *)inInvocation
{
NSAutoreleasePool *theAutoreleasePool = [[NSAutoreleasePool alloc] init];
//
[self addThread:[NSThread currentThread]];

[inInvocation invoke];

[self removeThread:[NSThread currentThread]];

[theAutoreleasePool release];
}

@end
