//
//  Plugin.h
//  Sketch Toolbox
//
//  Created by Shahruz Shaukat on 5/19/14.
//  Copyright (c) 2014 Shahruz Shaukat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Plugin : NSManagedObject


typedef NS_ENUM(UInt16, PluginState) {
    PluginStateUninstalled,
    PluginStateInstalled,
    PluginStateDownloading
};

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * owner;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSDate * installed;
@property (nonatomic, retain) NSData * downloadPath;
@property (nonatomic, retain) NSDate * lastModified;
@property (nonatomic, retain) NSString * directoryName;
@property (nonatomic) UInt32 stars;
@property (nonatomic) UInt16 state;

-(BOOL)isInstalled;

-(void)download;
-(void)delete;

-(NSString*)displayName;
-(NSURL*)repoURL;


@end
