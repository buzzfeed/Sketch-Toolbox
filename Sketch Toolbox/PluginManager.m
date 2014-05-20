//
//  PluginManager.m
//  Sketch Toolbox
//
//  Created by Shahruz Shaukat on 5/19/14.
//  Copyright (c) 2014 Shahruz Shaukat. All rights reserved.
//

#import "PluginManager.h"
#import "Plugin.h"
#import "SSZipArchive/SSZipArchive.h"
#import "STAppDelegate.h"

@implementation PluginManager

+ (id)sharedManager {
    static PluginManager *sharedPluginManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPluginManager = [[self alloc] init];
    });
    return sharedPluginManager;
}

-(NSArray*)getAllPlugins {
    return [Plugin MR_findAllSortedBy:@"name" ascending:YES];
}

-(Plugin *)upsertPlugin:(NSDictionary *)dictionary {
    Plugin *plugin = [Plugin MR_findFirstOrCreateByAttribute:@"name" withValue:dictionary[@"name"]];
    plugin.name = dictionary[@"name"];
    plugin.desc = dictionary[@"description"];
    plugin.owner = dictionary[@"owner"];
    if (!plugin.installed) plugin.installed = nil;
    return plugin;
}

-(void)updatePlugins {
    NSPredicate *installed = [NSPredicate predicateWithFormat:@"installed != nil"];
    NSArray *installedPlugins = [Plugin MR_findAllWithPredicate:installed];
    [installedPlugins enumerateObjectsUsingBlock:^(Plugin *plugin, NSUInteger idx, BOOL *stop) {
        [plugin download];
    }];
}

-(void)downloadCatalog {
    NSURL *requestURL = [NSURL URLWithString:@"https://raw.githubusercontent.com/sketchplugins/plugin-directory/master/plugins.json"];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSArray *remotePlugins = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    [remotePlugins enumerateObjectsUsingBlock:^(NSDictionary *p, NSUInteger idx, BOOL *stop) {
        [self upsertPlugin:p];
    }];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

@end
