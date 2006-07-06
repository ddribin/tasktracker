#import <Cocoa/Cocoa.h>

@interface NSManagedObject (JRExtensions)
+ (id)newInManagedObjectContext:(NSManagedObjectContext*)moc_;

+ (id)rootObjectInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (id)initAndInsertIntoManagedObjectContext:(NSManagedObjectContext*)moc_;

+ (NSArray*)fetchAllInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSArray*)fetchAllInManagedObjectContext:(NSManagedObjectContext*)moc_ error:(NSError**)error_;

+ (NSString*)entityNameByHeuristic; // MyCoolObjectMO => @"MyCoolObject".
+ (NSEntityDescription*)entityDescriptionInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSFetchRequest*)fetchRequestForEntityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@end

@interface NSManagedObjectContext (JRExtensions)
- (NSArray*)executeFetchRequestNamed:(NSString*)fetchRequestName_ error:(NSError**)error;
@end