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

-(IBAction)actionButtonPressed:(NSButton*)sender {
    if (!self.plugin.isInstalled) {
        self.actionButton.enabled = NO;
        [sender setTitle:@"Downloading..."];
        [self.plugin download];
    }
    else [self.plugin delete];
}

-(void)infoButtonPressed:(id)sender {
    [self openGitHubURL];
}

- (void)nameButtonPressed:(id)sender {
    [self openGitHubURL];
}

-(void)populate {
    self.nameButton.title = self.plugin.displayName;
    self.descriptionField.stringValue = self.plugin.desc;
    self.owner.stringValue = self.plugin.owner;
    self.starCount.stringValue = [NSString stringWithFormat:@"%i", self.plugin.stars];
    if (self.plugin.state == PluginStateInstalled) {
        self.actionButton.enabled = YES;
        [self.actionButton setTitle:@"Uninstall"];
    } else if (self.plugin.state == PluginStateDownloading) {
        self.actionButton.enabled = NO;
        [self.actionButton setTitle:@"Downloading..."];
    } else {
        self.actionButton.enabled = YES;
        [self.actionButton setTitle:@"Install"];
    }
}

- (void)openGitHubURL {
    [[NSWorkspace sharedWorkspace] openURL:self.plugin.repoURL];
}

@end
