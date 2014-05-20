//
//  STAppDelegate.m
//  Sketch Toolbox
//
//  Created by Shahruz Shaukat on 5/19/14.
//  Copyright (c) 2014 Shahruz Shaukat. All rights reserved.
//

#import "STAppDelegate.h"
#import "PluginManager.h"
#import "Plugin.h"
#import "STPluginCellView.h"

@interface STAppDelegate() {
    PluginManager *pluginManager;
    NSArray *plugins;
}
@end

@implementation STAppDelegate

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [MagicalRecord setupAutoMigratingCoreDataStack];
    
    pluginManager = [PluginManager sharedManager];
    [pluginManager downloadCatalog];
    
    plugins = [Plugin MR_findAllSortedBy:@"name" ascending:YES];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [plugins count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    STPluginCellView *pluginCell = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    Plugin *plugin = [plugins objectAtIndex:row];
    pluginCell.name.stringValue = plugin.name;
    pluginCell.description.stringValue = plugin.desc;
    pluginCell.plugin = plugin;
    return pluginCell;
}

- (BOOL)selectionShouldChangeInTableView:(NSTableView *)tableView {
    return NO;
}

- (NSString *)applicationFilesDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    return [paths[0] stringByAppendingPathComponent:@"Sketch Toolbox"];
}

- (IBAction)saveAction:(id)sender {
    NSError *error = nil;
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

@end
