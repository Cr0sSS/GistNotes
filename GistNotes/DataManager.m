//
//  DataManager.m
//  GistNotes
//
//  Created by Admin on 22.01.17.
//  Copyright © 2017 Andrey Kuznetsov. All rights reserved.
//

#import "ErrorController.h"
#import "DataManager.h"

#import "Gist+CoreDataClass.h"


@implementation DataManager

NSDateFormatter* isoDateFormat;

+ (DataManager*)sharedManager {
    
    static DataManager* manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [DataManager new];
        
        isoDateFormat = [NSDateFormatter new];
        [isoDateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    });
    
    return manager;
}


- (NSMutableArray*)gistsFromResponse:(NSArray*)response {
    
    NSMutableArray* gists = [NSMutableArray new];
    
    for (NSDictionary* details in response) {
        
        NSString* gistID = details[@"id"];
        Gist* gist = [self getGistWithID:gistID];
        
        if (!gist) {
            gist = [self createNewGistWithDetails:details];
        }

        [gists addObject:gist];
    }
    [self saveContext];
    
    return gists;
}


- (NSArray*)gistsWithNotes{
    NSArray* gists = [self getGistsWithNotes];
    return gists;
}


#pragma mark - Creates

- (Gist*)createNewGistWithDetails:(NSDictionary*)details {
    
    Gist* gist = [NSEntityDescription insertNewObjectForEntityForName:@"Gist"
                                               inManagedObjectContext:self.persistentContainer.viewContext];
    
    gist.gistID = details[@"id"];
    gist.edited = NO;
    gist.note = @"";
    gist.createDate = [isoDateFormat dateFromString:details[@"created_at"]];
    
    id name = details[@"description"];
    if ([name isKindOfClass:[NSNull class]]) {
        gist.name = @"";
        
    } else {
        gist.name = details[@"description"];
    }

    gist.ownerLogin = details[@"owner"][@"login"];
    gist.avatarURLString = details[@"owner"][@"avatar_url"];
    
    return gist;
}


#pragma mark - Gets

- (Gist*)getGistWithID:(NSString*)gistID {
    
    NSFetchRequest* request = [NSFetchRequest new];
    NSEntityDescription* entity = [NSEntityDescription entityForName:@"Gist"
                                              inManagedObjectContext:self.persistentContainer.viewContext];
    [request setEntity:entity];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"gistID == %@", gistID];
    [request setPredicate:predicate];
    
    NSError* error = nil;
    NSArray* result = [self.persistentContainer.viewContext executeFetchRequest:request error:&error];
    
    if (error) {
        [self showError:error];
    }
    
    return [result count] ? [result firstObject] : nil;
}


- (NSArray*)getGistsWithNotes {
    
    NSFetchRequest* request = [NSFetchRequest new];
    NSEntityDescription* entity = [NSEntityDescription entityForName:@"Gist"
                                              inManagedObjectContext:self.persistentContainer.viewContext];
    [request setEntity:entity];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"edited == YES"];
    [request setPredicate:predicate];
    
    NSSortDescriptor* dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createDate" ascending:NO];
    [request setSortDescriptors:@[dateDescriptor]];
    
    NSError* error = nil;
    NSArray* result = [self.persistentContainer.viewContext executeFetchRequest:request error:&error];
    
    if (error) {
        [self showError:error];
    }
    
    return result;
}


#pragma mark - Error

- (void)showError:(NSError*)error {
    [ErrorController errorControllerWithTitle:@"Data Error" message:[error localizedDescription]];
}


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"GistNotes"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    [self showError:error];
                    abort();
                }
            }];
        }
    }
    return _persistentContainer;
}


#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        [self showError:error];
        abort();
    }
}

@end
