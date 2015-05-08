//
//  STAppDelegate.h
//  Sketch Toolbox
//
//  Created by Shahruz Shaukat on 5/19/14.
//  Copyright (c) 2014 Shahruz Shaukat. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Constants.h"
#import "Plugin.h"

@interface STAppDelegate : NSObject <NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, strong) IBOutlet NSSegmentedControl *filterControl;
@property (nonatomic, strong) IBOutlet NSSearchField *searchField;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;
- (IBAction)importPlugin:(id)sender;
- (IBAction)exportPlugin:(id)sender;


- (IBAction)filterPlugins:(NSSearchField *)searchField;
- (IBAction)segmentSelected:(NSSegmentedControl*)sender;
- (IBAction)feedbackEmailClicked:(id)sender;


- (NSString *)applicationFilesDirectory;
- (void)reloadTableData;

@property (nonatomic, strong) IBOutlet NSTableView *tableView;
@property (nonatomic, strong) IBOutlet NSButton *refreshButton;

@end
