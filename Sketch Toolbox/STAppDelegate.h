//
//  STAppDelegate.h
//  Sketch Toolbox
//
//  Created by Shahruz Shaukat on 5/19/14.
//  Copyright (c) 2014 Shahruz Shaukat. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface STAppDelegate : NSObject <NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;


-(IBAction)filterPlugins:(NSSearchField *)searchField;
-(IBAction)segmentSelected:(NSSegmentedControl*)sender;

- (NSString *)applicationFilesDirectory;

@property (nonatomic, strong) IBOutlet NSTableView *tableView;

@end
