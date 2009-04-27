//	It appears NSManagedObjectModel prematurely releases its references to NSEntityDescriptions, causing weirdness and/or
//	crashes (chiefly with model-based fetch requests).
//	This poser tail-patches two bottleneck methods which seem to cover all my code paths, enabling the use of model-based
//	fetch requests.

#ifndef NSAppKitVersionNumber10_4
#define NSAppKitVersionNumber10_4 824
#endif

@interface NSManagedObjectModel_PatchRadar4828429 : NSManagedObjectModel
@end
@implementation NSManagedObjectModel_PatchRadar4828429
+ (void)load {
	if (floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_4) {
		//	On a 10.4 - 10.4.x system, need to load this patch.
		[NSManagedObjectModel_PatchRadar4828429 poseAsClass:[NSManagedObjectModel class]];
	}
}
- (id)initWithCoder:(NSCoder*)decoder_ {
	self = [super initWithCoder:decoder_];
	[[self entities] makeObjectsPerformSelector:@selector(retain)];
	return self;
}
- (NSFetchRequest*)fetchRequestFromTemplateWithName:(NSString*)name_ substitutionVariables:(NSDictionary*)variables_ {
	NSFetchRequest *fetchRequest = [super fetchRequestFromTemplateWithName:name_ substitutionVariables:variables_];
	[fetchRequest setEntity:[[self entitiesByName] objectForKey:[[fetchRequest entity] name]]];
	return fetchRequest;
}
@end
