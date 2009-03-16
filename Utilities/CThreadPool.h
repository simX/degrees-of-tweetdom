//
//  CThreadPool.h
//  OperationQueue
//
//  Created by Jonathan Wight on 3/13/07.
//  Copyright 2007 Toxic Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CThreadPool : NSObject {
	SEL selector;
	id target;
	id parameter;
	int desiredThreadCount;
	NSConditionLock *currentThreadCount;
	NSMutableArray *threads;
}

- (SEL)selector;
- (void)setSelector:(SEL)inSelector;

- (id)target;
- (void)setTarget:(id)inTarget;

- (id)parameter;
- (void)setParameter:(id)inParameter;

- (int)desiredThreadCount;
- (void)setDesiredThreadCount:(int)inDesiredThreadCount;

- (int)currentThreadCount;

- (void)waitUntilZeroThreads;

- (void)detachNewThreadSelector:(SEL)inSelector toTarget:(id)inTarget withObject:(id)inArgument;

@end
