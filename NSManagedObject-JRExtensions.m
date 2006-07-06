#import "NSManagedObject-JRExtensions.h"

@implementation NSManagedObject (JRExtensions)

+ (id)newInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	return [[[self alloc] initAndInsertIntoManagedObjectContext:moc_] autorelease];
}

+ (id)rootObjectInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSError *error = nil;
	NSArray *objects = [moc_ executeFetchRequest:[self fetchRequestForEntityInManagedObjectContext:moc_] error:&error];
	NSAssert( objects, @"-[NSManagedObjectContext executeFetchRequest] returned nil" );
	
	id result = nil;
	
	switch( [objects count] ) {
		case 0:
			[[moc_ undoManager] disableUndoRegistration];
			result = [self newInManagedObjectContext:moc_];
			[moc_ processPendingChanges];
			[[moc_ undoManager] enableUndoRegistration];
			break;
		case 1:
			result = [objects objectAtIndex:0];
			break;
		default:
			NSAssert2( NO, @"0 or 1 %@ objects expected, %d found", [self className], [objects count] );
	}
	
	return result;
}

- (id)initAndInsertIntoManagedObjectContext:(NSManagedObjectContext*)moc_ {
	return [self initWithEntity:[[self class] entityDescriptionInManagedObjectContext:moc_] insertIntoManagedObjectContext:moc_];
}

+ (NSString*)entityNameByHeuristic {
	NSString *result = [self className];
	if( [result hasSuffix:@"MO"] )
		result = [result substringToIndex:([result length]-2)];
	return result;
}

+ (NSEntityDescription*)entityDescriptionInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSEntityDescription *result = [NSEntityDescription entityForName:[self entityNameByHeuristic] inManagedObjectContext:moc_];
	if( nil == result ) {
		// Heuristic failed. Do it the hard way.
		NSString *className = [self className];
		NSManagedObjectModel *managedObjectModel = [[moc_ persistentStoreCoordinator] managedObjectModel];
		NSArray *entities = [managedObjectModel entities];
		unsigned entityIndex = 0, entityCount = [entities count];
		for( ; nil == result && entityIndex < entityCount; ++entityIndex ) {
			if( [[[entities objectAtIndex:entityIndex] managedObjectClassName] isEqualToString:className] )
				result = [entities objectAtIndex:entityIndex];
		}
		NSAssert1( result, @"no entity found with a managedObjectClassName of %@", className );
	}
	return result;
}

+ (NSFetchRequest*)fetchRequestForEntityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSFetchRequest *result = [[[NSFetchRequest alloc] init] autorelease];
	[result setEntity:[self entityDescriptionInManagedObjectContext:moc_]];
	return result;
}

+ (NSArray*)fetchAllInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	return [self fetchAllInManagedObjectContext:moc_ error:nil];
}

+ (NSArray*)fetchAllInManagedObjectContext:(NSManagedObjectContext*)moc_ error:(NSError**)error_ {
	return [moc_ executeFetchRequest:[self fetchRequestForEntityInManagedObjectContext:moc_]
							   error:error_];
}

@end

@implementation NSManagedObjectContext (JRExtensions)
- (NSArray*)executeFetchRequestNamed:(NSString*)fetchRequestName_ error:(NSError**)error_ {
	NSFetchRequest *fetchRequest = [[[self persistentStoreCoordinator] managedObjectModel] fetchRequestTemplateForName:fetchRequestName_];
	NSAssert1(fetchRequest, @"Can't find fetch request named \"%@\".", fetchRequestName_);
	return [self executeFetchRequest:fetchRequest error:error_];
}
@end