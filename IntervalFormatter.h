#import <Foundation/Foundation.h>

@interface IntervalFormatter : NSFormatter {
}

+ (NSString*)format:(NSTimeInterval)interval;

@end