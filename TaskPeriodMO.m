#import "TaskPeriodMO.h"

@implementation TaskPeriodMO

- (void)awakeFromInsert {
    [self setValue:[NSDate date] forKey:@"start"];
}

- (NSTimeInterval)calcInterval {
    NSDate *stop = [self valueForKey:@"stop"];
    if( stop == nil )
        stop = [NSDate date];
    return [stop timeIntervalSinceDate:[self valueForKey:@"start"]];
}

- (IBAction)stopAction:(id)sender {
	[self setValue:[NSDate date] forKey:@"stop"];
}

@end
