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
        [sender setTitle:@"Downloading..."];
        [self.plugin download];
        self.downloadingPercentage.hidden = NO;
        self.percentageLabel.hidden = NO;
        self.percentageLabel.stringValue = [NSString stringWithFormat:@"%lliMB/%lliMB %lld%%", [Plugin downloadedFileSize], [Plugin totalFileSize], ([Plugin downloadedFileSize]/[Plugin totalFileSize]) ];
        //self.downloadingPercentage = ;
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
        [self.actionButton setTitle:@"Uninstall"];
        self.downloadingPercentage.hidden = YES;
        self.percentageLabel.hidden = YES;
    } else if (self.plugin.state == PluginStateDownloading) {
        [self.actionButton setTitle:@"Downloading..."];
        self.downloadingPercentage.hidden = NO;
        self.percentageLabel.hidden = NO;
        self.percentageLabel.stringValue = [NSString stringWithFormat:@"%lliMB/%lliMB %lld%%", [Plugin downloadedFileSize], [Plugin totalFileSize], ([Plugin downloadedFileSize]/[Plugin totalFileSize])  ];
    } else {
        [self.actionButton setTitle:@"Install"];
        self.downloadingPercentage.hidden = YES;
        self.percentageLabel.hidden = YES;
    }
    //[STPluginCellView ];
}

- (void)openGitHubURL {
    [[NSWorkspace sharedWorkspace] openURL:self.plugin.repoURL];
}

@end
