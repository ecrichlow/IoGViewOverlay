# IoGViewOverlay Sample

v1.0 / (c) 2015 Infusions of Grandeur / Written By: Eric Crichlow

## Background

IoGViewOverlay Sample is a sample app created as a showcase and tutorial for the IoGViewOverlay class, which is designed to add supplemental display features to standard views.

The project was born out of a desire to have functionality similar to what many apps currently do, with having a secondary view controller slide over from the primary view controller, but in a more lightweight, (no secondary view controller needed,) and flexible, (multiple “sliders” can be available simultaneously,) manner.

The class gives developers the ability to add “tabs”, not to be confused with CoCoa Touch native tab bar tabs, to a view. These tabs, when selected, slide over the current view, almost entirely covering it, and exposing a supplemental view onto which the developer can add any native components.

Three types of supplemental views are supported: list view, which is implemented via a standard table view, grid view, which is implemented via a standard collection view, and freeform, which utilities a plain UIView.

## History

Version 1.0:	Initial release

## Classes

IoGViewOverlay

This is the subclass of UIView that is instantiated for the desired view controller.
It contains 9 properties of interest to the developer:

* position - location along the edge of the view to display the tab while its content is hidden. 
* contentType - which of the 3 possible overlay types the tab will utilize
* tabTitle - the name displayed on the tab selection “button”
* contentView - the containing view for the content to be displayed in the overlay
* tabBackgroundColor - color for the background of the tab selection “button”
* tabTitleColor - color for the text of the tab selection “button”
* contentBackgroundColor - color for the background of the content area of the overlay
* contentForegroundColor - color for textual items in the content area of the overlay
* itemsPerRow - the number of items to place in each row when using the grid content type

## Usage

Add the following 2 files to your project:

* IoGViewOverlay.h
* IoGViewOverlay.m

Create the desired overlays and call “show” on each of them to have them added to the view of the designated controller:

	- (void)viewDidLoad
	{

		[super viewDidLoad];
	
		NSArray *categoryItems = @[@{@"item":@"Home and Leisure", @"target":self, @"selector":NSStringFromSelector(@selector(categorySelected:))}, @{@"item":@"Electronics", @"target":self, @"selector":NSStringFromSelector(@selector(categorySelected:))}, @{@"item":@"Sports", @"target":self, @"selector":NSStringFromSelector(@selector(categorySelected:))}];
		NSArray *sectionItems = @[@{@"image":[UIImage imageNamed:@"HomeButton.png"], @"label":@"Home", @"target":self, @"selector":NSStringFromSelector(@selector(sectionSelected:))}, @{@"image":[UIImage imageNamed:@"LeisureButton.png"], @"label":@"Leisure", @"target":self, @"selector":NSStringFromSelector(@selector(sectionSelected:))}, @{@"image":[UIImage imageNamed:@"SportsButton.png"], @"label":@"Sports", @"target":self, @"selector":NSStringFromSelector(@selector(sectionSelected:))}, @{@"image":[UIImage imageNamed:@"GiftsButton.png"], @"label":@"Gifts", @"target":self, @"selector":NSStringFromSelector(@selector(sectionSelected:))}];
	
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

Three types of overlays are available:

* IogViewOverlayTypeList: utilizes the standard tableview to present a list
* IogViewOverlayTypeGrid: utilizes the standard collection view to present a grid of items
* IogViewOverlayTypeFreeForm: allows the developer a “blank slate” upon which to create a display

For list and grid types, you must create an array containing the items to be displayed and add the array to the overlay object. You should also define a target object and selector to call on that object as a callback for when each item is selected.

## Known Issues

The tabs and content views don’t currently adapt to device rotation.

Changes to tab properties are not respected after the tab has been displayed.

## Support

Questions, suggestions or contributions to the codebase can be submitted to support@infusionsofgrandeur.com

## License

Copyright 2015 Infusions of Grandeur

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

