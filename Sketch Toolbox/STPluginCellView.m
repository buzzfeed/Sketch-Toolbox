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

@end
