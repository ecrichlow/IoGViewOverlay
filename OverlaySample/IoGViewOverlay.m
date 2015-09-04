/*******************************************************************************
 * IoGViewOverlay.m
 *
 * Title:			IoGViewOverlay
 * Description:		View Overlay Slider UI Enhancement
 *						This file contains the enhancement's single
 *						implementation file
 * Author:			Eric Crichlow
 * Version:			1.0
 * Copyright:		(c) 2015 Infusions of Grandeur. All rights reserved.
 ********************************************************************************
 *	08/30/15		*	EGC	*	File creation date
 *******************************************************************************/

#import "IoGViewOverlay.h"

@interface IoGViewOverlay ()
@property (strong, nonatomic) UIViewController *parentController;	// The controller of the view that we will overlay and mostly, but not entirely, obscure
@property (assign, nonatomic) BOOL contentLaidOut;					// Flag for whether or not the contents of the overlay and the tab button have been positioned on the overlay yet
@property (strong, nonatomic) UIButton *tabButton;					// The button that serves as the "tab" for revealing and concealing the overlay's content
@property (assign, nonatomic) BOOL contentRevealed;					// Flag for whether or not the overlay is currently revealed or concealed
@property (assign, nonatomic) CGRect overlayConcealedFrame;			// The frame for the overlay when it is in the concealed position
@property (assign, nonatomic) CGRect visibleFrame;					// The frame for the area of the view visible on-screen. Takes into account the status bar, and navigation and tab bars if they are visible
@property (assign, nonatomic) BOOL contentNeedsUpdating;			// Flag for whether or not the list or grid needs to be updated with new options
@property (strong, nonatomic) UITableView *contentTable;			// If overlay is of type IoGViewOverlayTypeList, the table that displays the list
@property (strong, nonatomic) UICollectionView *contentGrid;		// If overlay is of type IoGViewOverlayTypeGrid, the collection view that displays the "buttons"
@property (assign, nonatomic) CGRect buttonFrame;					// Frame within the enclosing view that the "tab" button occupies
@end

@implementation IoGViewOverlay

#pragma mark - View LifeCycle

- (id)initForParentViewController:(UIViewController *)parent withPosition:(IoGViewOverlayTabPosition)placement contentType:(IoGViewOverlayType)contentType andTitle:(NSString *)title
{

	self = [super initWithFrame:parent.view.frame];

	if (self)
		{
		_parentController = parent;
		_position = placement;
		_contentType = contentType;
		_tabTitle = title;
		_contentLaidOut = NO;
		_contentRevealed = NO;
		_visibleFrame = [self calculateVisibleFrame];
		_contentNeedsUpdating = NO;
		itemList = [NSMutableArray array];
		}

	return (self);
}

// If touch is within the transparent "Tab" area, but isn't on this view's "tab", pass the touch through in case it's a tap on another "tab" behind this view
-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{

	if (point.x >= self.buttonFrame.origin.x && point.x <= (self.buttonFrame.origin.x + self.buttonFrame.size.width) && point.y >= self.buttonFrame.origin.y && point.y <= (self.buttonFrame.origin.y + self.buttonFrame.size.height))
		{
		return (YES);
		}
	else if (point.x >= self.contentView.frame.origin.x && point.x <= (self.contentView.frame.origin.x + self.contentView.frame.size.width) && point.y >= self.contentView.frame.origin.y && point.y <= (self.contentView.frame.origin.y + self.contentView.frame.size.height))
		{
		return (YES);
		}

    return NO;
}

- (BOOL)canBecomeFirstResponder
{
	return YES;
}

#pragma mark - Business Logic

- (void)addItem:(NSDictionary *)overlayItem
{
	[itemList addObject:overlayItem];
	self.contentNeedsUpdating = YES;
}

- (void)addItems:(NSArray *)items
{
	[itemList addObjectsFromArray:items];
	self.contentNeedsUpdating = YES;
}

- (void)show
{

	if (!self.contentLaidOut)				// If we haven't constructed the "tab" yet, we need to before we can show the it
		{
		[self setup];
		}
	if (self.contentNeedsUpdating)			// If the items on the tab haven't been laid out yet, or the list of items has changed, we need to update the layout
		{
		[self layoutContent];
		}
	self.tabButton.hidden = NO;
}

- (void)hide
{
	self.tabButton.hidden = YES;
}

- (void)toggleOverlayReveal
{
	[self tabClicked];
}

- (void)reveal
{

	if (!self.contentRevealed)
		{
		[UIView animateWithDuration:IoGViewOverlayDrawerSlideAnimationDuration animations:^{self.frame = self.visibleFrame;} completion:nil];
		self.contentRevealed = YES;
		}
}

- (void)conceal
{
	
	if (self.contentRevealed)
		{
		[UIView animateWithDuration:IoGViewOverlayDrawerSlideAnimationDuration animations:^{self.frame = self.overlayConcealedFrame;} completion:nil];
		self.contentRevealed = NO;
		}
}

- (void)setup
{

	if (self.parentController)
		{
		// First set up the enclosing transparent view
		CGRect frame = self.visibleFrame;
		CGRect contentFrame;
		CGFloat xpos = 0.0;
		CGFloat ypos = 0.0;
		CGAffineTransform buttonOrientationModifier;
		self.backgroundColor = [UIColor clearColor];
		self.alpha = IoGViewOverlayEnclosingViewAlpha;
		self.contentLaidOut = YES;
		self.userInteractionEnabled = YES;
		// Determine where to place the "tab" button
		switch (self.position)
			{
			case IoGViewOverlayTabPositionTopEdgeLeft:
			case IoGViewOverlayTabPositionTopEdgeCenter:
			case IoGViewOverlayTabPositionTopEdgeRight:
				if (self.position == IoGViewOverlayTabPositionTopEdgeLeft)
					{
					xpos = 0;
					}
				else if (self.position == IoGViewOverlayTabPositionTopEdgeCenter)
					{
					xpos = ((frame.size.width - (IoGViewOverlaySpaceBetweenHorizontalTabs * 2)) / 3) + IoGViewOverlaySpaceBetweenHorizontalTabs;
					}
				else if (self.position == IoGViewOverlayTabPositionTopEdgeRight)
					{
					xpos = (((frame.size.width - (IoGViewOverlaySpaceBetweenHorizontalTabs * 2)) / 3) * 2) + (IoGViewOverlaySpaceBetweenHorizontalTabs * 2);
					}
				self.buttonFrame = CGRectMake(xpos, frame.size.height - IoGViewOverlayTabOutset, (frame.size.width - (IoGViewOverlaySpaceBetweenHorizontalTabs * 2)) / 3, IoGViewOverlayTabOutset);
				contentFrame = CGRectMake(frame.origin.x, 0, frame.size.width, frame.size.height - IoGViewOverlayTabOutset);
				// Now set the frame to push the view offscreen except for the "tab" and keep that frame for future use
				frame.origin.y -= (frame.size.height - IoGViewOverlayTabOutset);
				self.overlayConcealedFrame = frame;
				// And finally, determnine how we should rotate the label for a sideways button
				buttonOrientationModifier = CGAffineTransformMakeRotation(0);
				break;
			case IoGViewOverlayTabPositionLeftEdgeTop:
			case IoGViewOverlayTabPositionLeftEdgeCenter:
			case IoGViewOverlayTabPositionLeftEdgeBottom:
				if (self.position == IoGViewOverlayTabPositionLeftEdgeTop)
					{
					ypos = 0;
					}
				else if (self.position == IoGViewOverlayTabPositionLeftEdgeCenter)
					{
					ypos = ((frame.size.height - (IoGViewOverlaySpaceBetweenVerticalTabs * 2)) / 3) + IoGViewOverlaySpaceBetweenVerticalTabs;
					}
				else if (self.position == IoGViewOverlayTabPositionLeftEdgeBottom)
					{
					ypos = (((frame.size.height - (IoGViewOverlaySpaceBetweenVerticalTabs * 2)) / 3) * 2) + (IoGViewOverlaySpaceBetweenVerticalTabs * 2);
					}
				self.buttonFrame = CGRectMake(frame.size.width - IoGViewOverlayTabOutset, ypos, IoGViewOverlayTabOutset, (frame.size.height - (IoGViewOverlaySpaceBetweenVerticalTabs * 2)) / 3);
				contentFrame = CGRectMake(frame.origin.x, 0, frame.size.width - IoGViewOverlayTabOutset, frame.size.height);
				// Now set the frame to push the view offscreen except for the "tab" and keep that frame for future use
				frame.origin.x -= (frame.size.width - IoGViewOverlayTabOutset);
				self.overlayConcealedFrame = frame;
				// And finally, determnine how we should rotate the label for a sideways button
				buttonOrientationModifier = CGAffineTransformMakeRotation(M_PI / 2);
				break;
			case IoGViewOverlayTabPositionBottomEdgeLeft:
			case IoGViewOverlayTabPositionBottomEdgeCenter:
			case IoGViewOverlayTabPositionBottomEdgeRight:
				if (self.position == IoGViewOverlayTabPositionBottomEdgeLeft)
					{
					xpos = 0;
					}
				else if (self.position == IoGViewOverlayTabPositionBottomEdgeCenter)
					{
					xpos = ((frame.size.width - (IoGViewOverlaySpaceBetweenHorizontalTabs * 2)) / 3) + IoGViewOverlaySpaceBetweenHorizontalTabs;
					}
				else if (self.position == IoGViewOverlayTabPositionBottomEdgeRight)
					{
					xpos = (((frame.size.width - (IoGViewOverlaySpaceBetweenHorizontalTabs * 2)) / 3) * 2) + (IoGViewOverlaySpaceBetweenHorizontalTabs * 2);
					}
				self.buttonFrame = CGRectMake(xpos, 0, (frame.size.width - (IoGViewOverlaySpaceBetweenHorizontalTabs * 2)) / 3, IoGViewOverlayTabOutset);
				contentFrame = CGRectMake(frame.origin.x, IoGViewOverlayTabOutset, frame.size.width, frame.size.height - IoGViewOverlayTabOutset);
				// Now set the frame to push the view offscreen except for the "tab" and keep that frame for future use
				frame.origin.y += (frame.size.height - IoGViewOverlayTabOutset);
				self.overlayConcealedFrame = frame;
				// And finally, determnine how we should rotate the label for a sideways button
				buttonOrientationModifier = CGAffineTransformMakeRotation(0);
				break;
			case IoGViewOverlayTabPositionRightEdgeTop:
			case IoGViewOverlayTabPositionRightEdgeCenter:
			case IoGViewOverlayTabPositionRightEdgeBottom:
				if (self.position == IoGViewOverlayTabPositionRightEdgeTop)
					{
					ypos = 0;
					}
				else if (self.position == IoGViewOverlayTabPositionRightEdgeCenter)
					{
					ypos = ((frame.size.height - (IoGViewOverlaySpaceBetweenVerticalTabs * 2)) / 3) + IoGViewOverlaySpaceBetweenVerticalTabs;
					}
				else if (self.position == IoGViewOverlayTabPositionRightEdgeBottom)
					{
					ypos = (((frame.size.height - (IoGViewOverlaySpaceBetweenVerticalTabs * 2)) / 3) * 2) + (IoGViewOverlaySpaceBetweenVerticalTabs * 2);
					}
				self.buttonFrame = CGRectMake(0, ypos, IoGViewOverlayTabOutset, (frame.size.height - (IoGViewOverlaySpaceBetweenVerticalTabs * 2)) / 3);
				contentFrame = CGRectMake(frame.origin.x + IoGViewOverlayTabOutset, 0, frame.size.width - IoGViewOverlayTabOutset, frame.size.height);
				// Now set the frame to push the view offscreen except for the "tab" and keep that frame for future use
				frame.origin.x += (frame.size.width - IoGViewOverlayTabOutset);
				self.overlayConcealedFrame = frame;
				// And finally, determnine how we should rotate the label for a sideways button
				buttonOrientationModifier = CGAffineTransformMakeRotation(-M_PI / 2);
				break;
			default:
				break;
			}
		self.tabButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		self.tabButton.backgroundColor = self.tabBackgroundColor;
		self.tabButton.alpha = IoGViewOverlayButtonAlpha;
		[self.tabButton setTitleColor:self.tabTitleColor forState:UIControlStateNormal];
		[self.tabButton setTitle:self.tabTitle forState:UIControlStateNormal];
		[self.tabButton setTransform:buttonOrientationModifier];
		self.tabButton.frame = self.buttonFrame;
		[self.tabButton addTarget:self action:@selector(tabClicked) forControlEvents:UIControlEventTouchUpInside];
		// Than add the content
		self.contentView = [[UIView alloc] initWithFrame:contentFrame];
		self.contentView.backgroundColor = self.contentBackgroundColor;
		self.contentView.alpha = IoGViewOverlayContentViewAlpha;
		self.contentView.userInteractionEnabled = YES;
		if (self.position == IoGViewOverlayTabPositionTopEdgeLeft || self.position == IoGViewOverlayTabPositionTopEdgeCenter || self.position == IoGViewOverlayTabPositionTopEdgeRight || self.position == IoGViewOverlayTabPositionBottomEdgeLeft || self.position == IoGViewOverlayTabPositionBottomEdgeCenter || self.position == IoGViewOverlayTabPositionBottomEdgeRight)
			{
			self.contentView.hidden = YES;
			}
		// Finally, put everything together
		[self addSubview:self.contentView];
		[self addSubview:self.tabButton];
		self.frame = self.overlayConcealedFrame;
		[self.parentController.view addSubview:self];
		}
}

- (void)layoutContent
{

	CGRect				bounds = self.contentView.bounds;

	if (self.contentType == IoGViewOverlayTypeList)
		{
		self.contentTable = [[UITableView alloc] initWithFrame:bounds style:UITableViewStylePlain];
		self.contentTable.delegate = self;
		self.contentTable.dataSource = self;
		self.contentTable.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.contentTable];
		}
	else if (self.contentType == IoGViewOverlayTypeGrid)
		{
		self.contentGrid = [[UICollectionView alloc] initWithFrame:bounds collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
		[self.contentGrid registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"IoGViewOverlayGridCell"];
		self.contentGrid.delegate = self;
		self.contentGrid.dataSource = self;
		[self.contentView addSubview:self.contentGrid];
		}

	self.contentNeedsUpdating = NO;
}

- (void)tabClicked
{

	if (!self.contentRevealed)
		{
		if (self.position == IoGViewOverlayTabPositionTopEdgeLeft || self.position == IoGViewOverlayTabPositionTopEdgeCenter || self.position == IoGViewOverlayTabPositionTopEdgeRight || self.position == IoGViewOverlayTabPositionBottomEdgeLeft || self.position == IoGViewOverlayTabPositionBottomEdgeCenter || self.position == IoGViewOverlayTabPositionBottomEdgeRight)
			{
			self.contentView.hidden = NO;
			}
		[UIView animateWithDuration:IoGViewOverlayDrawerSlideAnimationDuration animations:^{self.frame = self.visibleFrame;} completion:^(BOOL finished){[self.parentController.view bringSubviewToFront:self];}];
		}
	else
		{
		[UIView animateWithDuration:IoGViewOverlayDrawerSlideAnimationDuration animations:^{self.frame = self.overlayConcealedFrame;} completion:^(BOOL finished){if (self.position == IoGViewOverlayTabPositionTopEdgeLeft || self.position == IoGViewOverlayTabPositionTopEdgeCenter || self.position == IoGViewOverlayTabPositionTopEdgeRight || self.position == IoGViewOverlayTabPositionBottomEdgeLeft || self.position == IoGViewOverlayTabPositionBottomEdgeCenter || self.position == IoGViewOverlayTabPositionBottomEdgeRight){self.contentView.hidden = YES;}}];
		}
	self.contentRevealed = !self.contentRevealed;
}

// Need to adjust for the presence of the tab bar, if it exists over the parent view
- (CGRect)calculateVisibleFrame
{

	UIApplication			*app = [UIApplication sharedApplication];
	CGFloat					statusBarHeight = app.statusBarHidden ? 0 : app.statusBarFrame.size.height;
	CGRect					frame = self.parentController.view.frame;
	CGRect					visible_Frame;

	// Adjust for the status bar given that the frame now includes that region
	frame.origin.y += statusBarHeight;
	frame.size.height -= statusBarHeight;

	visible_Frame = frame;
	if (self.parentController.navigationController.navigationBar)
		{
		UINavigationBar *navBar = self.parentController.navigationController.navigationBar;
		visible_Frame.size.height -= navBar.frame.origin.y;
		visible_Frame.size.height -= navBar.frame.size.height;
		}
	if (self.parentController.tabBarController.tabBar)
		{
		UITabBar *tabBar = self.parentController.tabBarController.tabBar;
		visible_Frame.size.height -= tabBar.frame.size.height;
		}

	return (visible_Frame);
}

// Create a size assuming square grid images based on the width value, adding height for a label if labels are included
- (CGSize)calculateGridItemSizeWithLabel:(BOOL)addLabel
{

	CGFloat					squareDimension = 0.0;
	CGSize					gridSize;

	if (self.itemsPerRow)
		{
		squareDimension = self.visibleFrame.size.width * (1.0 - IoGViewOverlayGridItemBorderPercentage) / self.itemsPerRow;
		}
	else
		{
		squareDimension = self.visibleFrame.size.width * (1.0 - IoGViewOverlayGridItemBorderPercentage);
		}
	gridSize.width = squareDimension;
	if (addLabel)
		{
		gridSize.height = squareDimension + (squareDimension * IoGViewOverlayGridItemLabelPercentage);
		}
	else
		{
		gridSize.height = squareDimension;
		}

	return (gridSize);
}

#pragma mark - TableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (itemList.count);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
    UITableViewCell			*cell = [tableView dequeueReusableCellWithIdentifier:@"IoGViewOverlayCell"];
	NSDictionary			*cellItem = [itemList objectAtIndex:indexPath.row];
    
    if (cell == nil)
		{
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"IoGViewOverlayCell"];
		}

	cell.backgroundColor = [UIColor clearColor];
	cell.textLabel.textColor = self.contentForegroundColor;
	cell.textLabel.text = [cellItem objectForKey:@"item"];
	
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - TableView delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

	NSDictionary			*cellItem = [itemList objectAtIndex:indexPath.row];
	NSObject				*target = (NSObject *)[cellItem objectForKey:@"target"];
	SEL						selector = NSSelectorFromString([cellItem objectForKey:@"selector"]);

	if ([target respondsToSelector:selector])
		{
		[target performSelector:selector withObject:[NSDictionary dictionaryWithObjectsAndKeys:[cellItem objectForKey:@"item"], @"item", [NSNumber numberWithInt:(int)indexPath.row], @"index", nil] afterDelay:0.2];
		}

	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - CollectionView datasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return (itemList.count);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{

	UICollectionViewCell				*cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"IoGViewOverlayGridCell" forIndexPath:indexPath];
	CGSize								gridSize = [self calculateGridItemSizeWithLabel:([[itemList objectAtIndex:indexPath.row] valueForKey:@"label"] ? YES : NO)];
	CGSize								imageSize = [self calculateGridItemSizeWithLabel:NO];
	UIView								*backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, gridSize.width, gridSize.height)];
	UIImageView							*itemImage = [[UIImageView alloc] initWithImage:[[itemList objectAtIndex:indexPath.row] valueForKey:@"image"]];
	UILabel								*label = [[UILabel alloc] init];

	itemImage.frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
	[backgroundView addSubview:itemImage];
	if ([[itemList objectAtIndex:indexPath.row] valueForKey:@"label"])
		{
		label.frame = CGRectMake(0, imageSize.height, gridSize.width, gridSize.height * IoGViewOverlayGridItemLabelPercentage);
		label.textColor = self.contentForegroundColor;
		label.textAlignment = NSTextAlignmentCenter;
		label.text = [[itemList objectAtIndex:indexPath.row] valueForKey:@"label"];
		[backgroundView addSubview:label];
		}

	cell.backgroundView = backgroundView;

	return (cell);
}

#pragma mark - CollectionViewDelegateFlowLayout methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	
	NSDictionary			*cellItem = [itemList objectAtIndex:indexPath.row];
	NSObject				*target = (NSObject *)[cellItem objectForKey:@"target"];
	SEL						selector = NSSelectorFromString([cellItem objectForKey:@"selector"]);
	
	if ([target respondsToSelector:selector])
		{
		[target performSelector:selector withObject:[NSDictionary dictionaryWithObjectsAndKeys:[cellItem objectForKey:@"image"], @"item", [NSNumber numberWithInt:(int)indexPath.row], @"index", nil] afterDelay:0.2];
		}
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	return ([self calculateGridItemSizeWithLabel:([[itemList objectAtIndex:indexPath.row] valueForKey:@"label"] ? YES : NO)]);
}

@end
