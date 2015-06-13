//
//  T8DataBaseManager.m
//  T8DataKitDemo
//
//  Created by 琦张 on 15/6/2.
//  Copyright (c) 2015年 琦张. All rights reserved.
//

#import "T8DataBaseManager.h"

static const NSString *databaseQueueSpecific = @"com.tinfinite.databasequeue";

static FMDatabaseQueue *databaseDispatchQueue = nil;

static T8DataBaseManager *T8DatabaseSingleton = nil;

@interface T8DataBaseManager ()

@property (nonatomic, strong) NSString *databasePath;
@property (nonatomic, strong) FMDatabase *database;

@end

@implementation T8DataBaseManager

+ (T8DataBaseManager *)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        T8DatabaseSingleton = [[T8DataBaseManager alloc] init];
    });

    return T8DatabaseSingleton;
}

- (FMDatabaseQueue *)databaseQueue
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        databaseDispatchQueue = [[FMDatabaseQueue alloc] initWithPath:self.databasePath];
    });

    return databaseDispatchQueue;
}

- (void)dispatchOnDatabaseThread:(void (^)(FMDatabase *db))block synchronous:(bool)synchronous
{
    if (synchronous) {
        [[self databaseQueue] inDatabase:^(FMDatabase *db) {
            @autoreleasepool {
                block(db);
            }
        }];
    }else{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[self databaseQueue] inDatabase:^(FMDatabase *db) {
                @autoreleasepool {
                    block(db);
                }
            }];
        });
    }
}

- (NSString *)databasePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [paths objectAtIndex:0];
    NSString *databaseDir = [documentPath stringByAppendingPathComponent:@"T8DataBase"];
    NSError *error;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:databaseDir withIntermediateDirectories:YES attributes:nil error:&error]) {
        NSLog(@"T8DataBase path create error:%@", error.debugDescription);
    }
    NSString *finalPath = [databaseDir stringByAppendingPathComponent:@"T8DataBase_main.db"];
    return finalPath;
}

@end
