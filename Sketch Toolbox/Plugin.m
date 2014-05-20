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

@dynamic desc;
@dynamic installed;
@dynamic name;
@dynamic owner;

-(void)download {
    [self initiateDownload];
//    if (!self.installed) [self initiateDownload];
//    else { // Check if there are any updates available
//        
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//        NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
//        [dateFormatter setLocale:enUSPOSIXLocale];
//        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
//        
//        NSURL *url = [NSURL URLWithString:
//                      [NSString stringWithFormat:
//                       @"https://api.github.com/repos/%@/%@/commits?since=%@", self.owner, self.name,[dateFormatter stringFromDate:self.installed]]];
//
//        NSURLRequest *request = [NSURLRequest requestWithURL:url];
//
//        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//
//            NSArray *commits = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
//            if ([commits count]) [self initiateDownload];
//
//        }];
//        
//    }
}

-(void)initiateDownload {
    NSLog(@"Downloading %@", self.name);
    NSURL *url = [NSURL URLWithString:
                  [NSString stringWithFormat:
                   @"https://github.com/%@/%@/archive/master.zip", self.owner, self.name]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        // Write to /tmp
        NSString *tmpPath = [@"/tmp/" stringByAppendingPathComponent:
                             [NSString stringWithFormat:@"%@-%@.zip", self.owner, self.name]];
        NSString *tmpOutputPath = @"/tmp/";
        NSString *tmpContentsPath = [tmpOutputPath stringByAppendingPathComponent:
                                     [NSString stringWithFormat:@"%@-master", self.name]];
        [data writeToFile:tmpPath atomically:YES];
        [SSZipArchive unzipFileAtPath:tmpPath toDestination:tmpOutputPath];

        NSString *outputPath = [[NSString stringWithFormat:@"~/Library/Containers/com.bohemiancoding.sketch3/Data/Library/Application Support/com.bohemiancoding.sketch3/Plugins/%@", self.name]  stringByExpandingTildeInPath];

        NSFileManager *fm = [NSFileManager defaultManager];
        NSError *error;
        [fm moveItemAtPath:tmpContentsPath toPath:outputPath error:&error];
        if (error) return;

        self.installed = [NSDate date];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    }];

    
}

@end
