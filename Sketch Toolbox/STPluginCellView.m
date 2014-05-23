//
//  STPluginCellView.m
//  Sketch Toolbox
//
//  Created by Shahruz Shaukat on 5/19/14.
//  Copyright (c) 2014 Shahruz Shaukat. All rights reserved.
//

#import "STPluginCellView.h"
#import "Plugin.h"

#define kDownloadingTag 999

@implementation STPluginCellView

-(IBAction)actionButtonPressed:(NSButton*)sender {
    if (!self.plugin.isInstalled) {
        [self.actionButton setTag:kDownloadingTag];
        [sender setTitle:@"Downloading..."];
        [self.plugin download];
    }
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
        if (self.actionButton.tag == kDownloadingTag) self.actionButton.tag = 0;
        [self.actionButton setTitle:@"Uninstall"];
    } else if (self.actionButton.tag == kDownloadingTag) {
        [self.actionButton setTitle:@"Downloading..."];
    } else {
        [self.actionButton setTitle:@"Install"];
    }
}

@end
