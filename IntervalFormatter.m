#import "IntervalFormatter.h"

@implementation IntervalFormatter

#define kSecondsInOneMinute 60
#define kSecondsInOneHour   3600

+ (NSString*)format:(NSTimeInterval)interval {
	unsigned hours = 0, minutes = 0, seconds = 0;
	if( interval >= kSecondsInOneHour ) {
		hours = interval / kSecondsInOneHour;
		interval -= hours * kSecondsInOneHour;
	}
	if( interval >= kSecondsInOneMinute ) {
		minutes = interval / kSecondsInOneMinute;
		interval -= minutes * kSecondsInOneMinute;
	}
	seconds = interval;
	
	return [NSString stringWithFormat:@"%.2i:%.2i:%.2i", hours, minutes, seconds];	
}

- (NSString *)stringForObjectValue:(id)anObject {
	return [IntervalFormatter format:[anObject doubleValue]];
}

- (BOOL)getObjectValue:(id *)anObject forString:(NSString *)string errorDescription:(NSString **)error {
	return NO;
}

- (NSAttributedString *)attributedStringForObjectValue:(id)anObject withDefaultAttributes:(NSDictionary *)attributes {
	return [[[NSAttributedString alloc] initWithString:[self stringForObjectValue:anObject]] autorelease];
}

@end
