//
//  Plugin.m
//  Sketch Toolbox
//
//  Created by Shahruz Shaukat on 5/19/14.
//  Copyright (c) 2014 Shahruz Shaukat. All rights reserved.
//

#import "Plugin.h"
#import "SSZipArchive.h"

@implementation Plugin

@dynamic name;
@dynamic owner;
@dynamic desc;
@dynamic installed;
@dynamic stars;
@dynamic downloadPath;
@dynamic lastModified;
@dynamic directoryName;
@dynamic state;

#pragma mark - Main Methods
-(void)download {
    if (self.isInstalled) return;
    NSLog(@"Downloading %@", self.name);
    self.state = PluginStateDownloading;
    
    NSURL *url = [NSURL URLWithString:
                  [NSString stringWithFormat:
                   @"%@/archive/master.zip", self.repoURL]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSString *tmpPath = [@"/tmp/" stringByAppendingPathComponent:
                             [NSString stringWithFormat:@"%@-%@.zip", self.owner, self.name]];
        NSString *tmpOutputPath = @"/tmp/";
        NSString *tmpContentsPath = [tmpOutputPath stringByAppendingPathComponent:
                                     [NSString stringWithFormat:@"%@-master", self.name]];
        [data writeToFile:tmpPath atomically:YES];
        [SSZipArchive unzipFileAtPath:tmpPath toDestination:tmpOutputPath];
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:tmpPath error:nil];
        
        NSMutableArray *downloadPaths = [@[] mutableCopy];
        
        NSArray *paths = @[kSketch3AppStorePluginPath, kSketch3PluginPath, kSketch3BetaPluginPath, kSketch2AppStorePluginPath, kSketch2PluginPath];
        
        [paths enumerateObjectsUsingBlock:^(NSString *path, NSUInteger idx, BOOL *stop) {
            if ([fm fileExistsAtPath:[path stringByExpandingTildeInPath]]) {
                NSString *outputPath = [NSString stringWithFormat:@"%@/%@", [path stringByExpandingTildeInPath], self.displayName];
                [fm copyItemAtPath:tmpContentsPath toPath:outputPath error:nil];
                NSLog(@"Copied to %@", outputPath);
                [downloadPaths addObject:outputPath];
            }
        }];

        [fm removeItemAtPath:tmpContentsPath error:nil];
        
        NSLog(@"Finished downloading %@", self.name);
        self.downloadPath = [NSKeyedArchiver archivedDataWithRootObject:downloadPaths];
        self.installed = [NSDate date];
        self.state = PluginStateInstalled;
        
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"pluginStatusUpdated" object:nil];
    }];
    
}

-(void)delete {
    if (!self.isInstalled) return;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *downloadPaths = [NSKeyedUnarchiver unarchiveObjectWithData:self.downloadPath];
    [downloadPaths enumerateObjectsUsingBlock:^(NSString *downloadPath, NSUInteger idx, BOOL *stop) {
        [fm removeItemAtPath:downloadPath error:nil];
    }];
    self.installed = nil;
    self.downloadPath = nil;
    self.state = PluginStateUninstalled;
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"pluginStatusUpdated" object:nil];    
}

#pragma mark - Properties

-(BOOL)isInstalled {
    return self.state == PluginStateInstalled || self.state == PluginStateDownloading;
}

-(NSString*)displayName {
    return [[self.name stringByReplacingOccurrencesOfString:@"-" withString:@" "] capitalizedString];
}

-(NSURL*)repoURL {
    return [NSURL URLWithString:
            [NSString stringWithFormat:@"https://github.com/%@/%@", self.owner, self.name]];
}

@end
