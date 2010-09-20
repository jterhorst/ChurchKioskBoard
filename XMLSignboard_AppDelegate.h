//
//  XMLSignboard_AppDelegate.h
//  XMLSignboard
//
//  Created by Jason Terhorst on 10/27/08.
//  Copyright Jason Terhorst 2008 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CalendarStore/CalendarStore.h>

#import "SignDisplayController.h"


@interface XMLSignboard_AppDelegate : NSObject
{
	NSMutableArray * announcements;
	NSMutableArray * events;
	
	NSMutableArray * calendarObjects;
	
	SignDisplayController * newDisplay;
	
	NSTimer * xmlUpdateTimer;
	
	
	NSColor * backgroundColor;
	
	NSImage * logoImage;
	
	
	IBOutlet NSWindow * window;
	
	IBOutlet NSTextField * xmlSourceField;
	IBOutlet NSTableView * calendarTableView;
	
	IBOutlet NSTextField * churchNameField;
	IBOutlet NSColorWell * backgroundColorWell;
	IBOutlet NSImageView * logoImageView;
	
}

- (IBAction)changeLogo:(id)sender;
- (IBAction)changeBackgroundColor:(id)sender;


- (IBAction)startShow:(id)sender;
- (IBAction)resetSettings:(id)sender;
- (IBAction)quitNow:(id)sender;

- (NSString *)applicationSupportFolder;

- (void)loadXMLFile;
- (void)loadCalendars;


@end
