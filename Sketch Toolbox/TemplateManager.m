//
//  TemplateManager.m
//  Sketch Toolbox
//
//  Created by Shahruz Shaukat on 11/6/14.
//  Copyright (c) 2014 Shahruz Shaukat. All rights reserved.
//

#import "TemplateManager.h"
#import "Template.h"
#import "SSZipArchive/SSZipArchive.h"
#import "STAppDelegate.h"

@implementation TemplateManager

+ (id)sharedManager {
    static TemplateManager *sharedTemplateManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedTemplateManager = [[self alloc] init];
    });
    return sharedTemplateManager;
}

-(void)downloadCatalog {
    NSURL *requestURL = [NSURL URLWithString:kTemplateCatalogURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSArray *remoteTemplates = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    [remoteTemplates enumerateObjectsUsingBlock:^(NSDictionary *p, NSUInteger idx, BOOL *stop) {
        [self upsertTemplate:p];
    }];
}

-(NSArray *)localTemplates {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *paths = @[kSketch3AppStoreTemplatePath, kSketch3TemplatePath, kSketch3BetaTemplatePath];
    NSMutableArray *localTemplates = [@[] mutableCopy];
    
    [paths enumerateObjectsUsingBlock:^(NSString *path, NSUInteger idx, BOOL *stop) {
        path = [path stringByExpandingTildeInPath];
        NSArray *Templates = [fm contentsOfDirectoryAtPath:path error:nil];
        [Templates enumerateObjectsUsingBlock:^(NSString *fileName, NSUInteger idx, BOOL *stop) {
            if ([[fileName substringToIndex:1] isEqualToString:@"."]) return;
            Template *template = [Template MR_findFirstByAttribute:@"directoryName" withValue:fileName];
            if (!template) {
                [localTemplates addObject:@{@"fileName": fileName,
                                          @"fileURL": [path stringByAppendingPathComponent:fileName]
                                          }];
            }
        }];
    }];
    return [localTemplates copy];
}

#pragma mark - Private

-(void)upsertTemplate:(NSDictionary *)dictionary {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name = %@) AND (owner = %@)", dictionary[@"name"], dictionary[@"owner"]];
    
    Template *template = [Template MR_findFirstWithPredicate:predicate];
    
    if (!template) {
        template = [Template MR_createEntity];
        template.name = dictionary[@"name"];
        template.owner = dictionary[@"owner"];
        template.installed = nil;
        template.lastModified = [NSDate dateWithTimeIntervalSince1970:0];
        template.directoryName = template.displayName;
    }
    
    template.desc = dictionary[@"description"];
    
    if (template.isInstalled) {
        
        NSLog(@"Getting latest info for %@", template.name);
        
        NSURL *url = [NSURL URLWithString:
                      [NSString stringWithFormat:
                       @"https://api.github.com/repos/%@/%@", template.owner, template.name]];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            template.stars = [dataDict[@"stargazers_count"] intValue];
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
            NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            [formatter setLocale:posix];
            NSDate *pushed_date = [formatter dateFromString:dataDict[@"pushed_at"]];
            
            if (template.isInstalled && ([template.installed compare:pushed_date] == NSOrderedAscending)) {
                NSLog(@"Updating %@", template.name);
                [template download];
            }
            
            template.lastModified = [NSDate date];
            [self triggerUpdate];
        }];
        
    } else {
        template.lastModified = [NSDate date];
        [self triggerUpdate];
    }
}

-(void)triggerUpdate {
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TemplateStatusUpdated" object:nil];
}

@end
