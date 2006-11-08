#import <Cocoa/Cocoa.h>

@class TaskMO;

double calculateTotal( double dollarsPerHour, double secondsWorked );

@interface TaskDocumentMO : NSManagedObject {}

- (NSMutableSet*)tasksSet;

//--

// Access to-many relationship via -[NSObject mutableSetValueForKey:]
- (void)addTasksObject:(TaskMO *)value;
- (void)removeTasksObject:(TaskMO *)value;

@end
