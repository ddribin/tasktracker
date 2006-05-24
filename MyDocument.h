#import <Cocoa/Cocoa.h>
#import "TaskDocumentMO.h"

@interface MyDocument : NSPersistentDocument {
	NSTimer	*timer;
}

- (TaskDocumentMO*)taskDocument;

@end
