//
//  STPluginCellView.m
//  Sketch Toolbox
//
//  Created by Shahruz Shaukat on 5/19/14.
//  Copyright (c) 2014 Shahruz Shaukat. All rights reserved.
//

#import "STPluginCellView.h"
#import "Plugin.h"

@implementation STPluginCellView

-(IBAction)downloadButtonPressed:(id)sender {
    [self.plugin download];
}

-(void)populate {
    self.name.stringValue = self.plugin.name;
    self.description.stringValue = self.plugin.desc;
    if (self.plugin.installed > [NSDate dateWithTimeIntervalSince1970:978307200]) {
        [self.downloadButton setTransparent:YES];
        [self.downloadButton setEnabled:NO];
    } else {
        [self.downloadButton setTransparent:NO];
        [self.downloadButton setEnabled:YES];
    }
}

@end
