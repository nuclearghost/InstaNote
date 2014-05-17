//
//  DBManager.h
//  InstaNote
//
//  Created by Mark Meyer on 5/17/14.
//  Copyright (c) 2014 Mark Meyer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Dropbox/Dropbox.h>

@interface DBManager : NSObject <UIAlertViewDelegate>

+ (id) sharedManager;

-(void)handleUrl:(NSURL *)url;
-(DBFilesystem *)getFileSystem;
-(BOOL)accountAvailable;
-(void)initializeAccountLinkFromView:(UIViewController*)view;

@end
