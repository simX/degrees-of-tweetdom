/*
 *  CCocoaObject.h
 *  OperationQueue
 *
 *  Created by Jonathan Wight on 4/14/07.
 *  Copyright 2007 Toxic Software. All rights reserved.
 *
 */

#include <Foundation/Foundation.h>

class CCocoaObject {
	public:
		CCocoaObject()
			:	mObject(NULL)
			{
			}
			

		CCocoaObject(id inObject)
			:	mObject(inObject)
			{
			if (mObject != NULL)
				[mObject retain];
			}
		CCocoaObject(const CCocoaObject &inRHS)
			:	mObject(inRHS.mObject)
			{
			if (mObject != NULL)
				[mObject retain];
			}

		~CCocoaObject()
			{
			reset();
			}
	
		CCocoaObject &operator = (const CCocoaObject &inRHS)
			{
			if (this != &inRHS)
				{
				reset();
				mObject = inRHS.mObject;
				if (mObject != NULL)
					[mObject retain];
				}
			return(*this);
			}
		
		bool operator == (const CCocoaObject &inRHS) const
			{
			if (this == &inRHS)
				return(true);
			else
				return(operator == (inRHS.mObject));
			}
			
		bool operator == (id inObject) const
			{
			if (mObject == inObject)
				return(true);
			else
				return([mObject isEqual:inObject]);
			}

		bool operator < (const CCocoaObject &inRHS) const
			{
			if (this == &inRHS)
				return(false);
			else
				return(operator < (inRHS.mObject));
			}
			
		bool operator < (id inObject) const
			{
			if (mObject == inObject)
				return(false);
			else if ([mObject respondsToSelector:@selector(compare:)])
				return([(id)mObject compare:inObject] == NSOrderedAscending);
			}

		id object(void)
			{
			return(mObject);
			}

		void reset(void)
			{
			if (mObject)
				{
				[mObject release];
				mObject = NULL;
				}
			}
	
	protected:
		id mObject;
};