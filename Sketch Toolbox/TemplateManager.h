//
//  TemplateManager.h
//  Sketch Toolbox
//
//  Created by Shahruz Shaukat on 11/6/14.
//  Copyright (c) 2014 Shahruz Shaukat. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Template;

@interface TemplateManager : NSObject <NSURLConnectionDelegate>

+(id)sharedManager;

-(void)downloadCatalog;
-(NSArray*)localTemplates;

@end
