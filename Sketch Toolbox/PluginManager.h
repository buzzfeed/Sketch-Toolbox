//
//  PluginManager.h
//  Sketch Toolbox
//
//  Created by Shahruz Shaukat on 5/19/14.
//  Copyright (c) 2014 Shahruz Shaukat. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Plugin;

@interface PluginManager : NSObject <NSURLConnectionDelegate>

+(id)sharedManager;

-(void)downloadCatalog;
-(NSArray*)localPlugins;

@end
