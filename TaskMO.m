#import "TaskMO.h"
#import "TaskPeriodMO.h"
#import "TaskDocumentMO.h"
#import "MyDocument.h"
#import "NSManagedObject-JRExtensions.h"
#import "nsenumerate.h"

@implementation TaskMO

- (void)realAwakeFromInsert:(id)ignored {
	TaskDocumentMO *taskDocument = [(MyDocument*)[[NSDocumentController sharedDocumentController] currentDocument] taskDocument];
	NSAssert( taskDocument, nil );
	[self setValue:taskDocument forKey:@"owningDocument"];
}

- (void)awakeFromInsert {
	[self performSelectorOnMainThread:@selector(realAwakeFromInsert:)
						   withObject:nil
						waitUntilDone:NO];
}

- (BOOL)canStart {
	return [self valueForKey:@"activePeriod"] == nil;
}

- (BOOL)canStop {
	return [self valueForKey:@"activePeriod"] != nil;
}

- (IBAction)startAction:(id)sender {
    NSAssert( [self canStart], nil );
	
	TaskPeriodMO *taskPeriod = [TaskPeriodMO newInManagedObjectContext:[self managedObjectContext]];
	[taskPeriod setValue:self forKey:@"owningTask"];
	[self setValue:taskPeriod forKey:@"activePeriod"];
	
	[self willChangeValueForKey:@"canStart"];
	[self didChangeValueForKey:@"canStart"];
	[self willChangeValueForKey:@"canStop"];
	[self didChangeValueForKey:@"canStop"];
}

- (IBAction)stopAction:(id)sender {
    NSAssert( [self canStop], nil );
	
	TaskPeriodMO *taskPeriod = [self valueForKey:@"activePeriod"];
	[taskPeriod stopAction:nil];
	[self setValue:nil forKey:@"activePeriod"];
	
	[self willChangeValueForKey:@"canStart"];
	[self didChangeValueForKey:@"canStart"];
	[self willChangeValueForKey:@"canStop"];
	[self didChangeValueForKey:@"canStop"];
}

- (NSTimeInterval)calcInterval {
	NSTimeInterval result = 0.0;
	nsenumerate( [self valueForKey:@"periods"], TaskPeriodMO, period ) {
		result += [period calcInterval];
	};
	return result;
}

@end
