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

@end
