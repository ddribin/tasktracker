#import <Cocoa/Cocoa.h>

@interface TaskMO : NSManagedObject {}

- (BOOL)canStart;
- (BOOL)canStop;

- (IBAction)startAction:(id)sender;
- (IBAction)stopAction:(id)sender;

- (NSTimeInterval)calcInterval;

@end
