#import <Cocoa/Cocoa.h>
#import "TaskDocumentMO.h"

@interface MyDocument : NSPersistentDocument {
    IBOutlet NSArrayController * tasksController;
	NSTimer	*timer;
}

- (TaskDocumentMO*)taskDocument;

@end
