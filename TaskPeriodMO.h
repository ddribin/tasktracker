#import <Cocoa/Cocoa.h>

@interface TaskPeriodMO : NSManagedObject {}

- (NSTimeInterval)calcInterval;
- (IBAction)stopAction:(id)sender;

@end
