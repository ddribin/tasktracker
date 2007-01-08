#import "MyDocument.h"
#import "CoreData+JRExtensions.h"
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
		[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                                                               selector:@selector(willSleep:)
                                                                   name:NSWorkspaceWillSleepNotification
																 object:nil];
	}
	return self;
}

- (void)awakeFromNib {
    NSSortDescriptor * sd = [[NSSortDescriptor alloc] initWithKey:@"firstStartPeriod" ascending:YES];
#if 0
    [tasksController setSortDescriptors: [NSArray arrayWithObject: sd]];
#else
    // If executed immediately, an 'Unknown key in query. firstStartPeriod' exception is thrown
    // Should this be called from a different method?
    [tasksController performSelector: @selector(setSortDescriptors:)
                          withObject: [NSArray arrayWithObject: sd]
                          afterDelay: 0.0f];
#endif
    [sd release];
}

- (void)dealloc {
	[timer invalidate]; [timer release]; timer = nil;
	[[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
	[super dealloc];
}

- (void)updateCalcIntervalKVO:(NSTimer*)timer {
	NSManagedObjectContext *moc = [self managedObjectContext];
	[[moc undoManager] disableUndoRegistration]; {
		NSMutableSet *tasksNeedingUpdating = [NSMutableSet set];
		BOOL changed = NO;
		nsenumerate( [moc executeFetchRequestNamed:@"activePeriods" error:nil], TaskPeriodMO, period ) {
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
	NSArray *tasks = [TaskMO fetchAllInManagedObjectContext:[self managedObjectContext]];
	tasks = [tasks sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"firstStartPeriod" ascending:YES] autorelease]]];
	nsenumerate(tasks, TaskMO, task ) {
		NSString *taskDescription = [task valueForKey:@"taskDescription"];
		NSTimeInterval billedTime = [task calcInterval];
		if( [taskDescription hasSuffix:@"*"] ) {
			taskDescription = [taskDescription substringToIndex:[taskDescription length]-1];
			taskDescription = [taskDescription stringByAppendingFormat:@" (%@)", [IntervalFormatter format:billedTime]];
			billedTime = 0.0;
		}
		totalBilledTime += billedTime;
		[output appendFormat:@"  %@  %@\n", [IntervalFormatter format:billedTime], taskDescription ];
	}
	[output appendFormat:@"----------  -----------\n"];
	[output appendFormat:@"  %@  Total Time (%.3f hours or %.3f minutes)\n",
        [IntervalFormatter format:totalBilledTime],
        totalBilledTime/3600, totalBilledTime/60];
	[output appendFormat:@"%10.2f  Total Minutes\n", totalBilledTime/60];
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

- (void)willSleep:(NSNotification*)notification_ {
	nsenumerate( [TaskMO fetchAllInManagedObjectContext:[self managedObjectContext]], TaskMO, task ) {
		if ([task canStop])
			[task stopAction:nil];
	}
	if ([self fileURL]) {
		[self saveDocument:nil];
	}
}

@end
