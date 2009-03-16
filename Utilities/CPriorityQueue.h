//
//  CPriorityQueue.h
//  OperationQueue
//
//  Created by Jonathan Wight on 4/14/07.
//  Copyright 2007 Toxic Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CHeap;

@interface CPriorityQueue : NSObject {
	CHeap *heap;
	NSMutableDictionary *objects;
	NSString *priorityKey;
}

- (NSString *)priorityKey;
- (void)setPriorityKey:(NSString *)inPriorityKey;

- (unsigned)count;

- (void)pushObject:(id)inObject;
- (id)popObject;

- (BOOL)containsObject:(id)inObject;
- (void)addObject:(id)inObject;
- (void)removeObject:(id)inObject;

- (NSArray *)allObjects;

- (NSEnumerator *)objectEnumerator;

@end
