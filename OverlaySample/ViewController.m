/*******************************************************************************
 * ViewController.m
 *
 * Title:			IoGViewOverlay Sample
 * Description:		Demo App for IoGViewOverlay UI Enhancement
 *						This header file contains the implementation for the
 *						application's main (only) view
 * Author:			Eric Crichlow
 * Version:			1.0
 * Copyright:		(c) 2015 Infusions of Grandeur. All rights reserved.
 ********************************************************************************
 *	08/30/15		*	EGC	*	File creation date
 *******************************************************************************/

#import "ViewController.h"
#import "IoGViewOverlay.h"

@interface ViewController ()
@property (strong, nonatomic) IoGViewOverlay *accountTab;
@property (strong, nonatomic) IoGViewOverlay *categoriesTab;
@property (strong, nonatomic) IoGViewOverlay *sectionsTab;
@end

@implementation ViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad
{

	[super viewDidLoad];

	NSArray							*categoryItems = @[@{@"item":@"Home and Leisure", @"target":self, @"selector":NSStringFromSelector(@selector(categorySelected:))}, @{@"item":@"Electronics", @"target":self, @"selector":NSStringFromSelector(@selector(categorySelected:))}, @{@"item":@"Sports", @"target":self, @"selector":NSStringFromSelector(@selector(categorySelected:))}];
	NSArray							*sectionItems = @[@{@"image":[UIImage imageNamed:@"HomeButton.png"], @"label":@"Home", @"target":self, @"selector":NSStringFromSelector(@selector(sectionSelected:))}, @{@"image":[UIImage imageNamed:@"LeisureButton.png"], @"label":@"Leisure", @"target":self, @"selector":NSStringFromSelector(@selector(sectionSelected:))}, @{@"image":[UIImage imageNamed:@"SportsButton.png"], @"label":@"Sports", @"target":self, @"selector":NSStringFromSelector(@selector(sectionSelected:))}, @{@"image":[UIImage imageNamed:@"GiftsButton.png"], @"label":@"Gifts", @"target":self, @"selector":NSStringFromSelector(@selector(sectionSelected:))}];

	// Add View Overlays
	self.accountTab = [[IoGViewOverlay alloc] initForParentViewController:self withPosition:IoGViewOverlayTabPositionLeftEdgeTop contentType:IoGViewOverlayTypeFreeForm andTitle:@"Account"];
	self.accountTab.tabBackgroundColor = [UIColor blackColor];
	self.accountTab.tabTitleColor = [UIColor whiteColor];
	self.accountTab.contentBackgroundColor = [UIColor blueColor];
	[self.accountTab show];
	self.categoriesTab = [[IoGViewOverlay alloc] initForParentViewController:self withPosition:IoGViewOverlayTabPositionRightEdgeCenter contentType:IoGViewOverlayTypeList andTitle:@"Categories"];
	self.categoriesTab.tabBackgroundColor = [UIColor blackColor];
	self.categoriesTab.tabTitleColor = [UIColor whiteColor];
	self.categoriesTab.contentBackgroundColor = [UIColor darkGrayColor];
	self.categoriesTab.contentForegroundColor = [UIColor whiteColor];
	[self.categoriesTab addItems:categoryItems];
	[self.categoriesTab show];
	self.sectionsTab = [[IoGViewOverlay alloc] initForParentViewController:self withPosition:IoGViewOverlayTabPositionLeftEdgeBottom contentType:IoGViewOverlayTypeGrid andTitle:@"Sections"];
	self.sectionsTab.tabBackgroundColor = [UIColor blackColor];
	self.sectionsTab.tabTitleColor = [UIColor whiteColor];
	self.sectionsTab.contentBackgroundColor = [UIColor darkGrayColor];
	self.sectionsTab.contentForegroundColor = [UIColor whiteColor];
	self.sectionsTab.itemsPerRow = 3;
	[self.sectionsTab addItems:sectionItems];
	[self.sectionsTab show];
}

#pragma mark - Business Logic

- (void)categorySelected:(NSDictionary *)selectionInfo
{
	
	[self.categoriesTab conceal];
}

- (void)sectionSelected:(NSDictionary *)selectionInfo
{
	
	[self.sectionsTab conceal];
}

@end
