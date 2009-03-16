//
//  CHeap.h
//  OperationQueue
//
//  Created by Jonathan Wight on 3/13/07.
//  Copyright 2007 Toxic Software. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSComparisonResult (*ComparisonFunctionPtr)(id, id, void *);

@interface CHeap : NSObject {
	void *implementation;
	ComparisonFunctionPtr comparisonFunction;
	void *comparisonUserData;
}

- (id)init;
- (id)initWithArray:(NSArray *)inArray;

- (ComparisonFunctionPtr)comparisonFunction;
- (void)setComparisonFunction:(ComparisonFunctionPtr)inComparisonFunction;

- (void *)comparisonUserData;
- (void)setComparisonUserData:(void *)inComparisonUserData;

- (unsigned)count;

- (void)pushObject:(id)inObject;
- (id)popObject;

- (id)topObject;

- (BOOL)containsObject:(id)inObject;
- (void)addObject:(id)inObject;
- (void)removeObject:(id)inObject;

- (NSArray *)allObjects;

- (NSEnumerator *)objectEnumerator;

- (NSEnumerator *)poppingEnumerator;

- (void)rebuild;

@end
