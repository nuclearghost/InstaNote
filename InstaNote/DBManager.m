//
//  DBManager.m
//  InstaNote
//
//  Created by Mark Meyer on 5/17/14.
//  Copyright (c) 2014 Mark Meyer. All rights reserved.
//

#import "DBManager.h"

@interface DBManager ()

@property (strong, nonatomic) DBAccount *account;
@property (strong, nonatomic) DBFilesystem *fs;
@property (strong, nonatomic) DBAccountManager *manager;

@end

@implementation DBManager

+ (id)sharedManager {
    static DBManager *sharedDBManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDBManager = [[self alloc] init];
    });
    return sharedDBManager;
}

- (id)init {
    if (self = [super init]) {
        self.manager =
        [[DBAccountManager alloc] initWithAppKey:@"qcz9ufcp4js53qh" secret:@"qb18w7dktw2vv7b"];
        [DBAccountManager setSharedManager:self.manager];
        
        __weak DBManager *weakSelf = self;
        
        [self.manager addObserver:self block: ^(DBAccount *account) {
            [weakSelf accountUpdated:account];
        }];
        
        DBAccount *account = [self.manager.linkedAccounts objectAtIndex:0];
        if (account) {
            self.account = account;
            self.fs = [[DBFilesystem alloc] initWithAccount:account];
        }
    }
    return self;
}

- (void)dealloc {
    [self.manager removeObserver:self];
}

- (DBFilesystem*)getFileSystem {
    return self.fs;
}

-(void)handleUrl:(NSURL *)url {
    DBAccount *account = [[DBAccountManager sharedManager] handleOpenURL:url];
    if (account) {
        self.account = account;
        self.fs = [[DBFilesystem alloc] initWithAccount:account];
    }
}

-(BOOL)accountAvailable {
    if (self.account) {
        return YES;
    } else {
        return NO;
    }
}

-(void)initializeAccountLinkFromView:(UIViewController*)view {
    [self.manager linkFromController:view];
}

- (void)accountUpdated:(DBAccount *)account {
    NSLog(@"accountUpdated %@", account);
}


@end
