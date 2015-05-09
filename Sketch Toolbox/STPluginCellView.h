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

@property (nonatomic, strong) IBOutlet NSButton *nameButton;
@property (nonatomic, strong) IBOutlet NSTextField *descriptionField;
@property (nonatomic, strong) IBOutlet NSTextField *owner;
@property (nonatomic, strong) IBOutlet NSTextField *starCount;
@property (nonatomic, strong) IBOutlet NSButton *actionButton;
@property (nonatomic, strong) IBOutlet NSProgressIndicator *downloadingPercentage;
@property (nonatomic, strong) IBOutlet NSTextField *percentageLabel;

-(IBAction)actionButtonPressed:(id)sender;
-(IBAction)infoButtonPressed:(id)sender;
-(IBAction)nameButtonPressed:(id)sender;

-(void)populate;

@end
