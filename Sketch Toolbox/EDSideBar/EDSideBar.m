//
//  ECSideBar.h
//
//  Created by erndev 
//  BSD license. 
//
#import "EDSideBar.h"
#import <QuartzCore/QuartzCore.h>

#define ED_DEFAULT_BUTTON_HEIGHT	60.0
#define ED_DEFAULT_ANIM_DURATION	0.15
#pragma mark -
#pragma mark ECSideBarButtonCell interface
/* default cell  */
@interface ECSideBarButtonCell : NSButtonCell
{
	
}
@property (EDSideBarRetain) id realTarget;
@property (EDSideBarAssign) SEL realAction;
@end

#pragma mark -
#pragma mark ECSideBarButtonCell Implementation 

@implementation ECSideBarButtonCell
@synthesize realTarget;
@synthesize realAction;

- (void)setTextColor:(NSColor *)textColor
{
    NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc]
											initWithAttributedString:[self attributedTitle]];
    NSUInteger len = [attrTitle length];
    NSRange range = NSMakeRange(0, len);
    [attrTitle addAttribute:NSForegroundColorAttributeName
                      value:textColor
                      range:range];

    if (![attrTitle isEqualToAttributedString: [[NSMutableAttributedString alloc]
                                               initWithAttributedString:[self attributedTitle]]]){
        [self setAttributedTitle:attrTitle];
    }


#if !__has_feature(objc_arc)
    [attrTitle release];
#endif
}

-(id)init
{
	self = [super init];
	if( self )
	{
		[self setTextColor:[NSColor whiteColor]];
		[self setImagePosition:NSImageAbove];
		[self setFont:[NSFont fontWithName:@"Lucida Grande" size:11]];
        self.realTarget = nil;
        self.realAction = nil;
	}
	return self;
}

- (void)drawWithFrame:(NSRect)frame inView:(NSView *)view {
	
	NSColor *cellColor = nil;
	if( [self state] == NSOnState )
		cellColor = [NSColor colorWithDeviceWhite:54.0/255.0 alpha:1.0];
	else
		cellColor = [NSColor colorWithDeviceWhite:65.0/255.0 alpha:1.0];
	
	[cellColor setFill];
	NSRectFill(frame);
	[self drawBezelWithFrame:frame inView:view];
	
	// Hard coded positions, just for testing... Don't use this cell :-)
	NSRect rectTitle = NSMakeRect(frame.origin.x, frame.origin.y+frame.size.height-23, frame.size.width, 20);
	NSRect rectImage = NSMakeRect(frame.origin.x, frame.origin.y+5, frame.size.width, frame.size.height - 25);
	
	NSImage *image = nil;
	
	if( [self state] == NSOnState )
	{
		// [super drawImage:(NSImage *)[self image] withFrame:(NSRect)rectImage inView:(NSView *)view];
		[self setTextColor:[NSColor whiteColor]];
		image = [self image];
	}
	else {
		image = [self alternateImage]!=nil?[self alternateImage]:[self image];
		[self setTextColor:[NSColor lightGrayColor]];
	}
	
	[super drawImage:image withFrame:rectImage inView:view];
	[super drawTitle:(NSAttributedString *)[self attributedTitle] withFrame:(NSRect)rectTitle inView:(NSView *)view];
	
}

- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView *)view {
	
	
	NSColor *cellColor = nil;
	
	if( [self state] == NSOnState )
		cellColor = [NSColor colorWithDeviceWhite:54.0/255.0 alpha:1.0];
	else
		cellColor = [NSColor colorWithDeviceWhite:65.0/255.0 alpha:1.0];
	
	[cellColor setFill];
	NSRectFill(frame);
	
	// Emboss
	[[NSGraphicsContext currentContext] setShouldAntialias:NO];
	CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
	CGContextSetRGBFillColor(ctx, 37.0/255.0, 37.0/255.0, 37.0/255.0, 1.0);
	CGContextFillRect(ctx, CGRectMake(0.5, NSMaxY(frame)-2, frame.size.width-1, 1));
	CGContextSetRGBFillColor(ctx, 77.0/255.0, 77.0/255.0, 77.0/255.0, 1.0);
	CGContextFillRect(ctx, CGRectMake(0.5, NSMaxY(frame)-1, frame.size.width-1, 1));
	[[NSGraphicsContext currentContext] setShouldAntialias:YES];
	
	if( [self state] == NSOnState )
	{
		
		// upper shadow
		NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithDeviceWhite:(42.0/255.0) alpha:1.0] 
															 endingColor:[NSColor colorWithDeviceWhite:(56.0/255.0) alpha:1.0]];
		NSRect rectGradient = NSMakeRect(0-0.5, NSMinY(frame)-1-0.5, NSWidth(frame)-1, 4.0);
		NSBezierPath *path = [NSBezierPath bezierPathWithRect:rectGradient];
		[gradient drawInBezierPath:path angle:90];
#if !__has_feature(objc_arc)		
		[gradient release];
#endif		
	}
	
	// Inset in the right
	CGContextSetRGBFillColor(ctx, 53.0/255.0, 53.0/255.0, 53.0/255.0, 0.8);
	CGContextFillRect(ctx, CGRectMake(NSMaxX(frame)-2, NSMinY(frame), 1.0, frame.size.height));
	CGContextSetRGBFillColor(ctx, 18.0/255.0, 18.0/255.0, 18.0/255.0, 1.0);
	CGContextFillRect(ctx, CGRectMake(NSMaxX(frame)-1, NSMinY(frame), 1.0, frame.size.height));
	
	
}

@end






#pragma mark -
#pragma mark ECSideBar(Private)

@interface EDSideBar(Private)
-(NSButtonCell*)addButton;
-(void)resizeMatrix;
-(void)moveSelectionImage;
@end

#pragma mark -
#pragma mark ECSideBar

@implementation EDSideBar

@synthesize backgroundColor=_backgroundColor;
@synthesize buttonsHeight;
@synthesize sidebarDelegate;
@synthesize layoutMode;
@synthesize cellClass;
@synthesize animateSelection;
@synthesize animationDuration;
@synthesize noiseAlpha;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		
        // Initialization code here.
		layoutMode = ECSideBarLayoutCenter;
		self.backgroundColor = [NSColor colorWithDeviceWhite:60.0/255.0 alpha:1.0];
		animationDuration = ED_DEFAULT_ANIM_DURATION;
		animateSelection = NO;
		_matrix = [[NSMatrix alloc] initWithFrame:NSZeroRect];
		[_matrix setBackgroundColor:_backgroundColor];
		[_matrix setMode:NSRadioModeMatrix];
		[_matrix setAllowsEmptySelection:NO];
		// Defaults
		[_matrix setCellClass:[ECSideBarButtonCell class]];
		[self addSubview:_matrix];
		[self setButtonsHeight :ED_DEFAULT_BUTTON_HEIGHT];
		[_matrix setDrawsBackground:YES];
		
		// Setup resize notification
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewResized:)
													 name:NSViewFrameDidChangeNotification object:self];
		
	}
    return self;
}
-(void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
#if !__has_feature(objc_arc)
	[_backgroundColor dealloc];
	[_matrix dealloc];
	[super dealloc];
#endif
}

-(void)drawBackground:(NSRect)rect
{
	[_backgroundColor set];
	NSRectFill(rect);
	if( self.noiseAlpha > 0 )
    {
        static CIImage *noisePattern = nil;
        if(noisePattern == nil){
            CIFilter *randomGenerator = [CIFilter filterWithName:@"CIColorMonochrome"];
            [randomGenerator setValue:[[CIFilter filterWithName:@"CIRandomGenerator"] valueForKey:@"outputImage"]
                               forKey:@"inputImage"];
            [randomGenerator setDefaults];
            noisePattern = [randomGenerator valueForKey:@"outputImage"];
#if !__has_feature(objc_arc)
            [noisePattern  retain];
#endif
        }
        [noisePattern drawAtPoint:NSZeroPoint fromRect:self.bounds operation:NSCompositePlusLighter fraction:noiseAlpha];
        
    }
}


- (void)drawRect:(NSRect)dirtyRect {
	
	[self drawBackground:dirtyRect];
}


-(void)selectButtonAtRow:(NSUInteger)row
{
	NSUInteger rowToSelect = row;
	if(  [_matrix numberOfRows]< row )
		rowToSelect =0;
	[_matrix setState:(NSInteger)NSOnState atRow:(NSInteger)rowToSelect column:(NSInteger)0];
	[self moveSelectionImage];
}

-(void)addButtonWithTitle:(NSString*)title
{
	
	NSCell * cell = [self addButton];
	[cell setTitle:title];
}
-(void)addButtonWithTitle:(NSString*)title image:(NSImage*)image
{
	NSCell * cell = [self addButton];
	[cell setTitle:title];
	[cell setImage:image];
}

-(void)addButtonWithTitle:(NSString*)title image:(NSImage*)image alternateImage:(NSImage*)alternateImage
{
	NSButtonCell * cell = [self addButton];
	[cell setTitle:title];
	[cell setImage:image];
	[cell setAlternateImage:alternateImage];
}

-(void)setTarget:(id)aTarget withSelector:(SEL)aSelector atIndex:(NSInteger)anIndex
{
    id cell = [_matrix cellAtRow:anIndex column:0];
    
    if ([cell isKindOfClass:[ECSideBarButtonCell class]]) {
        ECSideBarButtonCell *ecCell = (ECSideBarButtonCell *) cell;
        
        ecCell.realTarget = aTarget;
        ecCell.realAction = aSelector;
    }    
}

-(void)setCellClass:(Class)class
{
	[_matrix setCellClass:class];
}

-(void)setLayoutMode:(ECSideBarLayoutMode)mode
{
	layoutMode = mode;
	[self resizeMatrix];
}

-(void)setButtonsHeight:(CGFloat)heigth
{
	buttonsHeight = heigth;
	[_matrix setCellSize:NSMakeSize([self frame].size.width, heigth)];
	[_matrix setIntercellSpacing:NSMakeSize(0.0, 0.0)];
	[self resizeMatrix];
}

-(void)setSelectionImage:(NSImage*)img
{
	if( selectorImageView == nil )
	{
		NSRect r = [self frame];
		
		selectorImageView = [[NSImageView alloc]initWithFrame:NSMakeRect(NSMaxX(r)-img.size.width, NSMinY(r), img.size.width, img.size.height)];
        [selectorImageView setImage:img];
        [selectorImageView setAutoresizingMask:NSViewNotSizable];
		
		[_matrix addSubview:selectorImageView positioned:NSWindowAbove relativeTo:nil];
	}
	[selectorImageView setImage:img];
	[self moveSelectionImage];
}

-(id)cellForItem:(NSInteger)index
{
	if( index <0 || index > [_matrix numberOfRows] )
		return nil;
	id cell = [_matrix cellAtRow:index column:0];
	return cell;
}


-(void)buttonClicked:(id)sender
{
	[self moveSelectionImage];
    
    NSInteger row = [_matrix selectedRow];
    id cell = [_matrix cellAtRow:row column:0];
    
    if ([cell isKindOfClass:[ECSideBarButtonCell class]]) {
        ECSideBarButtonCell *ecCell = (ECSideBarButtonCell *) cell;
        
        if (ecCell.realTarget && ecCell.realAction &&
            [ecCell.realTarget respondsToSelector:ecCell.realAction]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [ecCell.realTarget performSelector:ecCell.realAction withObject:self];
#pragma clang diagnostic pop            
            return;
        }
    }
    
    if( sidebarDelegate && [sidebarDelegate respondsToSelector:@selector(sideBar:didSelectButton:)] ) {
		[sidebarDelegate sideBar:self didSelectButton:row];
	}
}

-(void)selectNext
{
    NSInteger row = [_matrix selectedRow] + 1;
    if (row >= [_matrix.cells count])
        return;
    
    [_matrix selectCellAtRow:row column:0];
    [self buttonClicked:self];
}

-(void)selectPrev
{
    NSInteger row = [_matrix selectedRow] - 1;
    if (row <= 0)
        return;
    
    [_matrix selectCellAtRow:row column:0];
    [self buttonClicked:self];
}

-(NSInteger)selectedIndex
{
    return [_matrix selectedRow];
}

@end

#pragma mark -
#pragma mark ECSideBar(Private)

@implementation EDSideBar(Private)

-(void)moveSelectionImage
{
	
	if( selectorImageView == nil )
		return;
	NSInteger row = [_matrix selectedRow];
	if( row == -1 )
		return;
	NSRect rect = [_matrix cellFrameAtRow:(NSInteger)row column:(NSInteger)0];
	
	// Move image view to the new position
	NSRect imgFrame = [selectorImageView frame];
	imgFrame.origin.y = rect.origin.y + NSHeight(rect)/2.0 - [[selectorImageView image] size].height/2.0	;
	imgFrame.origin.x = rect.origin.x + NSWidth(rect)-[[selectorImageView image] size].width;
	
	if( !animateSelection )
		[selectorImageView setFrame:imgFrame];
	else {
		
		[[NSAnimationContext currentContext] setDuration:animationDuration];
		[[selectorImageView animator] setFrame:imgFrame];
		
	}	
}


- (void)viewResized:(NSNotification *)notification
{
	[self resizeMatrix];
}

-(NSButtonCell*)addButton
{
	[_matrix addRow];
	NSButtonCell * cell = [_matrix cellAtRow:[_matrix numberOfRows]-1 column:0];
	[cell setButtonType:NSPushOnPushOffButton];
	[cell setTarget:self];
	[cell setAction:@selector(buttonClicked:)];
	[cell setFocusRingType:NSFocusRingTypeNone];
	
	[self resizeMatrix];
	return cell;
}


-(void)resizeMatrix
{
	NSInteger numRows = [_matrix numberOfRows];
	CGFloat matrixHeight = numRows * buttonsHeight;
	
	NSRect rect = [self frame];
	
	NSRect matrixRect = rect;
	matrixRect.origin.x = 0.0;
	matrixRect.size.width = NSWidth(rect);
	matrixRect.size.height = matrixHeight;
	if( layoutMode == ECSideBarLayoutTop )
	{
		matrixRect.origin.y = NSHeight(rect)-matrixHeight;
	}
	else if ( layoutMode == ECSideBarLayoutCenter )
	{
		matrixRect.origin.y = ((NSHeight(rect)-matrixHeight)/2.0);
	}
	else if ( layoutMode == ECSideBarLayoutBottom)
	{
		matrixRect.origin.y = 0.0;
		
	}
	[_matrix setFrame:matrixRect];
	
	[self moveSelectionImage];
	
}

@end

