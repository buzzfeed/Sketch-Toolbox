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

-(IBAction)actionButtonPressed:(id)sender {
    if (!self.plugin.isInstalled) [self.plugin download];
    else [self.plugin delete];
}

-(void)infoButtonPressed:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:self.plugin.repoURL];
}

-(void)populate {
    self.name.stringValue = self.plugin.displayName;
    self.description.stringValue = self.plugin.desc;
    self.owner.stringValue = self.plugin.owner;
    self.starCount.stringValue = [NSString stringWithFormat:@"%i", self.plugin.stars];
    if (self.plugin.isInstalled) {
        [self.actionButton setImage:[NSImage imageNamed:@"Trash"]];
    } else {
        [self.actionButton setImage:[NSImage imageNamed:@"Download"]];
    }
}

@end
