#import "MyDocument.h"
#import "NSManagedObject-JRExtensions.h"
#import "nsenumerate.h"
#import "TaskMO.h"
#import "TaskPeriodMO.h"
#import "IntervalFormatter.h"

@implementation MyDocument

- (id)init {
	self = [super init];
	if( self ) {
		timer = [[NSTimer scheduledTimerWithTimeInterval:1.0
												  target:self
												selector:@selector(updateCalcIntervalKVO:)
												userInfo:nil
												 repeats:YES] retain];
	}
	return self;
}

- (void)dealloc {
	[timer invalidate]; [timer release]; timer = nil;
	[super dealloc];
}

- (void) updateCalcIntervalKVO:(NSTimer*)timer {
	NSManagedObjectContext *moc = [self managedObjectContext];
	[[moc undoManager] disableUndoRegistration]; {
		NSFetchRequest *activePeriodsFetchRequest = [[[moc persistentStoreCoordinator] managedObjectModel]  fetchRequestTemplateForName:@"activePeriods"];
		NSAssert( activePeriodsFetchRequest, nil );
		NSMutableSet *tasksNeedingUpdating = [NSMutableSet set];
		BOOL changed = NO;
		nsenumerate( [moc executeFetchRequest:activePeriodsFetchRequest error:nil], TaskPeriodMO, period ) {
			changed = YES;
			[period willChangeValueForKey:@"calcInterval"];
			[period didChangeValueForKey:@"calcInterval"];
			[tasksNeedingUpdating addObject:[period valueForKey:@"owningTask"]];
		}
		nsenumerate( tasksNeedingUpdating, TaskMO, task ) {
			[task willChangeValueForKey:@"calcInterval"];
			[task didChangeValueForKey:@"calcInterval"];
		}
		if( changed ) {
			[[self taskDocument] willChangeValueForKey:@"calcTotal"];
			[[self taskDocument] didChangeValueForKey:@"calcTotal"];
		}
	}
	[[moc undoManager] enableUndoRegistration];
}

- (NSString *)windowNibName {
    return @"MyDocument";
}

- (TaskDocumentMO*)taskDocument {
	return [TaskDocumentMO rootObjectInManagedObjectContext:[self managedObjectContext]];
}

static void paste( NSString *string ) {
	[[NSPasteboard generalPasteboard] declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
	[[NSPasteboard generalPasteboard] setString:[string copy] forType:NSStringPboardType];
}

- (IBAction)copyTextReport:(id)sender {
	NSMutableString *output = [NSMutableString string];
	
	[output appendFormat:@"Time        Description\n"];
	[output appendFormat:@"----------  -----------\n"];
	NSTimeInterval totalBilledTime = 0;
	nsenumerate( [TaskMO fetchAllInManagedObjectContext:[self managedObjectContext]], TaskMO, task ) {
		NSString *taskDescription = [task valueForKey:@"taskDescription"];
		NSTimeInterval billedTime = [task calcInterval];
		if( [taskDescription hasSuffix:@"*"] ) {
			taskDescription = [taskDescription substringToIndex:[taskDescription length]-1];
			billedTime = 0.0;
		}
		totalBilledTime += billedTime;
		[output appendFormat:@"  %@  %@\n", [IntervalFormatter format:billedTime], taskDescription ];
	}
	[output appendFormat:@"----------  -----------\n"];
	[output appendFormat:@"  %@  Total Time\n", [IntervalFormatter format:totalBilledTime]];
	NSNumberFormatter *moneyFormatter = [[[NSNumberFormatter alloc] init] autorelease]; [moneyFormatter setFormat:@"__,__0.00"];
	
	double dollarsPerHour = [[[self taskDocument] valueForKey:@"dollarsPerHour"] doubleValue];
	[output appendFormat:@"$%@  Rate/Hour\n", [moneyFormatter stringForObjectValue:[NSNumber numberWithDouble:dollarsPerHour]]];
	//[output appendFormat:@"$%8.2f  Total Due\n", totalBilledTime*(85.00/(60.0*60.0))];
	[output appendFormat:@"$%@  Total Due\n", [moneyFormatter stringForObjectValue:[NSNumber numberWithDouble:calculateTotal(dollarsPerHour,totalBilledTime)]]];
	
	//Time        Description
	//----------  -----------
	//  03:07:56  Did something.
	//----------
	// 888:88:88  Total Time
	//$   100.00  Rate/Hour
	//$88,888.88  Total Due
	
	paste( output );
}

@end
