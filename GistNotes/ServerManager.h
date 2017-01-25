//
//  ServerManager.h
//  GistNotes
//
//  Created by Admin on 22.01.17.
//  Copyright © 2017 Andrey Kuznetsov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServerManager : NSObject

+ (ServerManager*)sharedManager;

- (void)getPublicGistsFromServerOnPage:(NSInteger)page
                             onSuccess:(void(^)(NSMutableArray* gists))success
                             onFailure:(void(^)(NSError* error))failure;

@end
