//
//  STPluginCellView.h
//  Sketch Toolbox
//
//  Created by Shahruz Shaukat on 5/19/14.
//  Copyright (c) 2014 Shahruz Shaukat. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Plugin;

@interface STPluginCellView : NSTableCellView

@property (nonatomic, strong) Plugin *plugin;

@property (nonatomic, strong) IBOutlet NSTextField *name;
@property (nonatomic, strong) IBOutlet NSTextField *description;

-(IBAction)downloadButtonPressed:(id)sender;

@end
