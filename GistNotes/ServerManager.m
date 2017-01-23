//
//  ServerManager.m
//  GistNotes
//
//  Created by Admin on 22.01.17.
//  Copyright © 2017 Andrey Kuznetsov. All rights reserved.
//

#import "ServerManager.h"
#import "DataManager.h"

#import "AFNetworking.h"

@interface ServerManager ()

@property (strong, nonatomic) AFHTTPSessionManager* sessionManager;

@end

@implementation ServerManager

+ (ServerManager*)sharedManager {
    static ServerManager* manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [ServerManager new];
    });
    
    return manager;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        NSURL* baseURL = [NSURL URLWithString:@"https://api.github.com/"];
        self.sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    }
    return self;
}


#pragma mark - GETs

- (void)getPublicGistsFromServerOnSuccess:(void(^)(NSMutableArray* gists))success
                                onFailure:(void(^)(NSError* error))failure {
    
    NSDictionary* params = @{@"per_page" : @"100",
                             @"page" : @"1"};

    [self.sessionManager GET:@"gists/public"
                  parameters:params
                    progress:nil
                     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                         
                         NSArray* response = responseObject;
                         NSMutableArray* gists = [[DataManager sharedManager] gistsFromResponse:response];
                         
                         if (success) {
                             success(gists);
                         }
        
                     }
                     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                         
                         if (failure) {
                             failure(error);
                         }
                     }];
    
}


- (void)getExtraPublicGistsFromServerOnPage:(NSInteger)page
                                  onSuccess:(void(^)(NSMutableArray* gists))success
                                  onFailure:(void(^)(NSError* error))failure {
    
    NSDictionary* params = @{@"per_page" : @"100",
                             @"page" : [NSNumber numberWithInteger:page]};
    
    [self.sessionManager GET:@"gists/public"
                  parameters:params
                    progress:nil
                     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                         
                         NSArray* response = responseObject;
                         NSMutableArray* gists = [[DataManager sharedManager] gistsFromResponse:response];
                         
                         if (success) {
                             success(gists);
                         }
                         
                     }
                     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                         
                         if (failure) {
                             failure(error);
                         }
                     }];
    
}


@end
