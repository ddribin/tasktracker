#import <Cocoa/Cocoa.h>
#import "TaskDocumentMO.h"

@interface MyDocument : NSPersistentDocument {
    IBOutlet NSArrayController * tasksController;
    IBOutlet NSArrayController * taskPeriodsController;
	NSTimer	*timer;
}

- (TaskDocumentMO*)taskDocument;

@end
