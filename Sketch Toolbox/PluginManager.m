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
    NSURL *requestURL = [NSURL URLWithString:@"https://raw.githubusercontent.com/sketchplugins/plugin-directory/master/plugins.json"];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSArray *remotePlugins = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    [remotePlugins enumerateObjectsUsingBlock:^(NSDictionary *p, NSUInteger idx, BOOL *stop) {
        [self upsertPlugin:p];
    }];
}

-(void)upsertPlugin:(NSDictionary *)dictionary {

    Plugin *plugin = [Plugin MR_findFirstOrCreateByAttribute:@"name" withValue:dictionary[@"name"]];
    plugin.name = dictionary[@"name"];
    plugin.desc = dictionary[@"description"];
    plugin.owner = dictionary[@"owner"];
    
    NSURL *url = [NSURL URLWithString:
                  [NSString stringWithFormat:
                   @"https://api.github.com/repos/%@/%@", plugin.owner, plugin.name]];

    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        plugin.stars = [dataDict[@"stargazers_count"] intValue];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
        NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        [formatter setLocale:posix];
        NSDate *pushed_date = [formatter dateFromString:dataDict[@"pushed_at"]];
        
        if (plugin.isInstalled && ([plugin.installed compare:pushed_date] == NSOrderedAscending)) {
            NSLog(@"Updating %@", plugin.name);
            [plugin download];
        }
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"pluginStatusUpdated" object:nil];        
    }];
}

@end
