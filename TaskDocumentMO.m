#import "TaskDocumentMO.h"
#import "TaskPeriodMO.h"
#import "NSManagedObject-JRExtensions.h"
#import "nsenumerate.h"

double calculateTotal( double dollarsPerHour, double secondsWorked ) {
	double dollarsPerSecond = dollarsPerHour / 3600;
	return secondsWorked * dollarsPerSecond;
}

@implementation TaskDocumentMO

- (double)calcTotal {
	NSTimeInterval totalSeconds = 0.0;
	
	nsenumerate ([[self managedObjectContext] executeFetchRequestNamed:@"billablePeriods" error:nil], TaskPeriodMO, period) {
		totalSeconds += [period calcInterval];
	}
	
	return calculateTotal( [[self valueForKey:@"dollarsPerHour"] doubleValue], totalSeconds );
}

- (NSMutableSet*)tasksSet {
	return [self mutableSetValueForKey:@"tasks"];
}

//--

- (void)addTasksObject:(TaskMO *)value 
{    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    
    [self willChangeValueForKey:@"tasks" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    
    [[self primitiveValueForKey: @"tasks"] addObject: value];
    
    [self didChangeValueForKey:@"tasks" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    
    [changedObjects release];
}

- (void)removeTasksObject:(TaskMO *)value 
{
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    
    [self willChangeValueForKey:@"tasks" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    
    [[self primitiveValueForKey: @"tasks"] removeObject: value];
    
    [self didChangeValueForKey:@"tasks" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    
    [changedObjects release];
}

@end
