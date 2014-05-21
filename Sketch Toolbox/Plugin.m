//
//  Plugin.m
//  Sketch Toolbox
//
//  Created by Shahruz Shaukat on 5/19/14.
//  Copyright (c) 2014 Shahruz Shaukat. All rights reserved.
//

#import "Plugin.h"
#import "SSZipArchive.h"

NSString *const kSketchAppStorePluginPath = @"~/Library/Containers/com.bohemiancoding.sketch3/Data/Library/Application Support/com.bohemiancoding.sketch3/Plugins/";
NSString *const kSketchBetaPluginPath = @"~/Library/Application Support/com.bohemiancoding.sketch3/Plugins/";

@implementation Plugin

@dynamic name;
@dynamic owner;
@dynamic desc;
@dynamic installed;
@dynamic stars;
@dynamic downloadPath;
@dynamic lastModified;

#pragma mark - Main Methods
-(void)download {
    if (self.isInstalled) return;
    NSLog(@"Downloading %@", self.name);
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
        
        if ([fm fileExistsAtPath:[kSketchAppStorePluginPath stringByExpandingTildeInPath]]) {
            NSString *outputPath = [NSString stringWithFormat:@"%@/%@", [kSketchAppStorePluginPath stringByExpandingTildeInPath], self.displayName];
            [fm copyItemAtPath:tmpContentsPath toPath:outputPath error:nil];
            [downloadPaths addObject:outputPath];
        }
        
        if ([fm fileExistsAtPath:[kSketchBetaPluginPath stringByExpandingTildeInPath]]) {
            NSString *outputPath = [NSString stringWithFormat:@"%@/%@", [kSketchBetaPluginPath stringByExpandingTildeInPath], self.displayName];
            [fm copyItemAtPath:tmpContentsPath toPath:outputPath error:nil];
            [downloadPaths addObject:outputPath];
        }
        
        [fm removeItemAtPath:tmpContentsPath error:nil];
        
        NSLog(@"Finished downloading %@", self.name);
        self.downloadPath = [NSKeyedArchiver archivedDataWithRootObject:downloadPaths];
        self.installed = [NSDate date];
        
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
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"pluginStatusUpdated" object:nil];    
}

#pragma mark - Properties

-(BOOL)isInstalled {
    return self.installed != nil;
}

-(NSString*)displayName {
    return [[self.name stringByReplacingOccurrencesOfString:@"-" withString:@" "] capitalizedString];
}

-(NSURL*)repoURL {
    return [NSURL URLWithString:
            [NSString stringWithFormat:@"https://github.com/%@/%@", self.owner, self.name]];
}

@end
