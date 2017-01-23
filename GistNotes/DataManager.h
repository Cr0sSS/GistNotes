//
//  DataManager.h
//  GistNotes
//
//  Created by Admin on 22.01.17.
//  Copyright © 2017 Andrey Kuznetsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DataManager : NSObject

@property (readonly, strong) NSPersistentContainer *persistentContainer;


+ (DataManager*)sharedManager;

- (NSMutableArray*)gistsFromResponse:(NSArray*)response;


- (void)saveContext;

@end
