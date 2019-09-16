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

-(void)downloadCatalog {
    NSURL *requestURL = [NSURL URLWithString:kPluginCatalogURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSArray *remotePlugins = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    [remotePlugins enumerateObjectsUsingBlock:^(NSDictionary *p, NSUInteger idx, BOOL *stop) {
        [self upsertPlugin:p];
    }];
}

-(NSArray *)localPlugins {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *paths = @[kSketch3AppStorePluginPath, kSketch3PluginPath, kSketch3BetaPluginPath,kSketch2AppStorePluginPath, kSketch2PluginPath];
    NSMutableArray *localPlugins = [@[] mutableCopy];
    
    [paths enumerateObjectsUsingBlock:^(NSString *path, NSUInteger idx, BOOL *stop) {
        path = [path stringByExpandingTildeInPath];
        NSArray *plugins = [fm contentsOfDirectoryAtPath:path error:nil];
        [plugins enumerateObjectsUsingBlock:^(NSString *fileName, NSUInteger idx, BOOL *stop) {
            if ([[fileName substringToIndex:1] isEqualToString:@"."]) return;
            Plugin *plugin = [Plugin MR_findFirstByAttribute:@"directoryName" withValue:fileName];
            if (!plugin) {
                [localPlugins addObject:@{@"fileName": fileName,
                                         @"fileURL": [path stringByAppendingPathComponent:fileName]
                                         }];
            }
        }];
    }];
    return [localPlugins copy];
}

#pragma mark - Private

-(void)upsertPlugin:(NSDictionary *)dictionary {

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name = %@) AND (owner = %@)", dictionary[@"name"], dictionary[@"owner"]];
    
    Plugin *plugin = [Plugin MR_findFirstWithPredicate:predicate];
    
    if (!plugin) {
        plugin = [Plugin MR_createEntity];
        plugin.name = dictionary[@"name"];
        plugin.owner = dictionary[@"owner"];
        plugin.installed = nil;
        plugin.lastModified = [NSDate dateWithTimeIntervalSince1970:0];
        plugin.directoryName = plugin.displayName;
    }

    plugin.desc = dictionary[@"description"];
    
    if (plugin.isInstalled) {
    
        NSLog(@"Getting latest info for %@", plugin.name);
        
        NSURL *url = [NSURL URLWithString:
                      [NSString stringWithFormat:
                       @"https://api.github.com/repos/%@/%@", plugin.owner, plugin.name]];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            plugin.stars = [dataDict[@"stargazers_count"] intValue];
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
            NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            [formatter setLocale:posix];
            NSDate *pushed_date = [formatter dateFromString:dataDict[@"pushed_at"]];
            
            if (plugin.isInstalled && ([plugin.installed compare:pushed_date] == NSOrderedAscending)) {
                NSLog(@"Updating %@", plugin.name);
                [plugin download];
            }
            
            plugin.lastModified = [NSDate date];
            [self triggerUpdate];
        }];

    } else {
        plugin.lastModified = [NSDate date];
        [self triggerUpdate];
    }
}

-(void)triggerUpdate {
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"pluginStatusUpdated" object:nil];
}

@end
