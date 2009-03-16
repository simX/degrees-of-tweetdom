//
//  NSConditionLock_Extensions.m
//  OperationQueue
//
//  Created by Jonathan Wight on 3/13/07.
//  Copyright (c) 2007 Toxic Software. All rights reserved.
//

#import "NSConditionLock_Extensions.h"

@implementation NSConditionLock (NSConditionLock_Extensions)

- (void)setCondition:(int)inCondition;
{
[self tryLock];
[self unlockWithCondition:inCondition];
}

@end
