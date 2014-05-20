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
    NSArray *activePlugins;
}
@end

@implementation STAppDelegate

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [MagicalRecord setupAutoMigratingCoreDataStack];
    [self getLatest];
}

-(void)getLatest {
    pluginManager = [PluginManager sharedManager];
    [pluginManager downloadCatalog];
    [pluginManager updatePlugins];
    [self startApp];
}


-(void)startApp {
    plugins = [Plugin MR_findAllSortedBy:@"name" ascending:YES];
    activePlugins = plugins;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self.tableView
                                             selector:@selector(reloadData)
                                                 name:@"pluginDownloaded"
                                               object:nil];

}

-(void)triggerUpdates:(id)sender {
    [pluginManager updatePlugins];
}

-(IBAction)filterPlugins:(NSSearchField *)searchField {
	NSMutableString *searchText = [NSMutableString stringWithString:[searchField stringValue]];
	NSLog(@"searchText: %@", searchText);
	
	while ([searchText rangeOfString:@"  "].location != NSNotFound) {
		[searchText replaceOccurrencesOfString:@"  " withString:@" " options:0 range:NSMakeRange(0, [searchText length])];
	}
	if ([searchText length] != 0) [searchText replaceOccurrencesOfString:@" " withString:@"" options:0 range:NSMakeRange(0,1)];
	if ([searchText length] != 0) [searchText replaceOccurrencesOfString:@" " withString:@"" options:0 range:NSMakeRange([searchText length]-1, 1)];
	if ([searchText length] == 0) {
		activePlugins = plugins;
        [self.tableView reloadData];        
		return;
	}

	NSArray *searchTerms = [searchText componentsSeparatedByString:@" "];

	if ([searchTerms count] == 1) {
		NSPredicate *p = [NSPredicate predicateWithFormat:@"(name contains[cd] %@) OR (desc contains[cd] %@) OR (owner contains[cd] %@)", searchText, searchText, searchText];
		activePlugins = [Plugin MR_findAllWithPredicate:p];
	} else {
		NSMutableArray *subPredicates = [[NSMutableArray alloc] init];
		for (NSString *term in searchTerms) {
			NSPredicate *p = [NSPredicate predicateWithFormat:@"(name contains[cd] %@) OR (album contains[cd] %@) OR (artist contains[cd] %@)", term, term, term];
			[subPredicates addObject:p];
		}
		NSPredicate *cp = [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
		
		activePlugins = [Plugin MR_findAllWithPredicate:cp];
	}
    [self.tableView reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [activePlugins count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    STPluginCellView *pluginCell = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    Plugin *plugin = [activePlugins objectAtIndex:row];
    pluginCell.plugin = plugin;
    [pluginCell populate];
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
