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

#import "TemplateManager.h"
#import "Template.h"

@interface STAppDelegate() {
    PluginManager *pluginManager;
    NSArray *plugins;
    NSArray *activePlugins;

    TemplateManager *templateManager;
    NSArray *templates;
    NSArray *activeTemplates;
}
@end

@implementation STAppDelegate

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

#pragma mark - Main app

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [MagicalRecord setupAutoMigratingCoreDataStack];
    [self migrate];
    [self setupSidebar];
    [self startApp];
    
    pluginManager = [PluginManager sharedManager];
    [pluginManager downloadCatalog];

    templateManager = [TemplateManager sharedManager];
    [templateManager downloadCatalog];
}

-(void)setupSidebar {
    [self.sidebarView setLayoutMode:ECSideBarLayoutTop];
    self.sidebarView.animateSelection = YES;
    self.sidebarView.sidebarDelegate = self;
    [self.sidebarView addButtonWithTitle:@"Plugins" image:[NSImage imageNamed:@"Plugins"] alternateImage:[NSImage imageNamed:@"Plugins-Gray.png"]];
    [self.sidebarView addButtonWithTitle:@"Templates" image:[NSImage imageNamed:@"Plugins"] alternateImage:[NSImage imageNamed:@"Plugins-Gray.png"]];
    [self.sidebarView selectButtonAtRow:0];
}

-(void)sideBar:(EDSideBar*)tabBar didSelectButton:(NSInteger)button {
    [self.tableView reloadData];
}

-(void)migrate {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *currentAppVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
//    NSString *previousVersion = [defaults objectForKey:@"appVersion"];
//    if (!previousVersion) {
//        NSArray *allPlugins = [Plugin MR_findAll];
//        [allPlugins enumerateObjectsUsingBlock:^(Plugin *plugin, NSUInteger idx, BOOL *stop) {
//            [plugin delete];
//        }];
//        [Plugin MR_truncateAll];
//    }
    [defaults setObject:currentAppVersion forKey:@"appVersion"];
    [defaults synchronize];
}

-(void)startApp {
    plugins = [Plugin MR_findAllSortedBy:@"name" ascending:YES];
    activePlugins = plugins;
    
    templates = [Template MR_findAllSortedBy:@"name" ascending:YES];
    activeTemplates = templates;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.refreshButton.toolTip = @"Check for updates";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableData) name:@"pluginStatusUpdated" object:nil];
}

-(IBAction)feedbackEmailClicked:(id)sender {
    NSString *mailtoAddress = [[NSString stringWithFormat:@"mailto:sketch@shahr.uz?Subject=[Sketch Toolbox] Feedback on version %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]] stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:mailtoAddress]];
}

#pragma mark - Plugins Table

-(void)reloadTableData {
    if (self.searchField.stringValue.length) {
        [self filterPlugins:self.searchField];
        return;
    }
    if (self.filterControl.selectedSegment == 0) {
        plugins = [Plugin MR_findAllSortedBy:@"name" ascending:YES];
        activePlugins = plugins;
        templates = [Template MR_findAllSortedBy:@"name" ascending:YES];
        activeTemplates = templates;
    } else if (self.filterControl.selectedSegment == 1) {
        NSPredicate *installed = [NSPredicate predicateWithFormat:@"installed != nil"];
        activePlugins = [Plugin MR_findAllSortedBy:@"name" ascending:YES withPredicate:installed];
        activeTemplates = [Template MR_findAllSortedBy:@"name" ascending:YES withPredicate:installed];
    }
    [self.tableView reloadData];
}

-(IBAction)segmentSelected:(NSSegmentedControl*)sender {
    if (sender.selectedSegment == 0) {
        activePlugins = plugins;
        activeTemplates = templates;
    } else if (sender.selectedSegment == 1) {
        NSPredicate *installed = [NSPredicate predicateWithFormat:@"installed != nil"];
        activePlugins = [Plugin MR_findAllSortedBy:@"name" ascending:YES withPredicate:installed];
        activeTemplates = [Template MR_findAllSortedBy:@"name" ascending:YES withPredicate:installed];
    }
    [self.tableView reloadData];
}

-(IBAction)filterPlugins:(NSSearchField *)searchField {
	NSMutableString *searchText = [NSMutableString stringWithString:[searchField stringValue]];
	while ([searchText rangeOfString:@"  "].location != NSNotFound) {
		[searchText replaceOccurrencesOfString:@"  " withString:@" " options:0 range:NSMakeRange(0, [searchText length])];
	}
	if ([searchText length] != 0) [searchText replaceOccurrencesOfString:@" " withString:@"" options:0 range:NSMakeRange(0,1)];
	if ([searchText length] != 0) [searchText replaceOccurrencesOfString:@" " withString:@"" options:0 range:NSMakeRange([searchText length]-1, 1)];
	if ([searchText length] == 0) {
        [self segmentSelected:self.filterControl];
		return;
	}
	NSArray *searchTerms = [searchText componentsSeparatedByString:@" "];
	if ([searchTerms count] == 1) {
        NSPredicate *p = [NSPredicate predicateWithFormat:@"(name contains[cd] %@) OR (desc contains[cd] %@) OR (owner contains[cd] %@)", searchText, searchText, searchText];
        NSMutableArray *predicates = [@[p] mutableCopy];
        if (self.filterControl.selectedSegment == 1) {
            [predicates addObject:[NSPredicate predicateWithFormat:@"installed != nil"]];
        }
        activePlugins = [Plugin MR_findAllWithPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:predicates]];
        activeTemplates = [Template MR_findAllWithPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:predicates]];
	} else {
		NSMutableArray *subPredicates = [[NSMutableArray alloc] init];
		for (NSString *term in searchTerms) {
			NSPredicate *p = [NSPredicate predicateWithFormat:@"(name contains[cd] %@) OR (desc contains[cd] %@) OR (owner contains[cd] %@)", term, term, term];
			[subPredicates addObject:p];
		}
        if (self.filterControl.selectedSegment == 1) {
            [subPredicates addObject:[NSPredicate predicateWithFormat:@"installed != nil"]];
        }
		NSPredicate *cp = [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
        activePlugins = [Plugin MR_findAllWithPredicate:cp];
        activeTemplates = [Template MR_findAllWithPredicate:cp];
	}
    [self.tableView reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if (self.sidebarView.selectedIndex == 0) return [activePlugins count];
    else if (self.sidebarView.selectedIndex == 1) return [activeTemplates count];
    return 0;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (self.sidebarView.selectedIndex == 0) {
        STPluginCellView *pluginCell = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
        Plugin *plugin = [activePlugins objectAtIndex:row];
        pluginCell.plugin = plugin;
        [pluginCell populate];
        return pluginCell;
    } else if (self.sidebarView.selectedIndex == 1) {
        STPluginCellView *templateCell = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
        Template *template = [activeTemplates objectAtIndex:row];
        templateCell.plugin = (Plugin*)template;
        [templateCell populate];
        return templateCell;
    }
    return nil;
}

- (BOOL)selectionShouldChangeInTableView:(NSTableView *)tableView {
    return NO;
}

-(IBAction)checkForUpdates:(id)sender {
    [pluginManager downloadCatalog];
    [templateManager downloadCatalog];
}

#pragma mark - Core Data

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
