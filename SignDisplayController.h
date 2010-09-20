//
//  SignDisplayController.h
//  XMLSignboard
//
//  Created by Jason Terhorst on 11/7/08.
//  Copyright 2008 Jason Terhorst. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

#import "SignView.h"
#import "FullScreenWindow.h"


@interface SignDisplayController : NSWindowController {
	
	// for the presenter...
	FullScreenWindow * presentationWindow;
	SignView * presentationView;
	
	NSMutableArray * announcements;
	NSMutableArray * events;
	
	NSMutableDictionary * selectedSlide;
	
	NSTimer * nextPageTimer;
	NSTimer * clockTimer;
	
	CGImageRef logoImageRef;
	
	// title screen
	CATextLayer * logoTitleLayer;
	CALayer * logoImageLayer;
	
	// header
	CATextLayer * leftHeaderBlock;
	CATextLayer * clock;
	
	// content
	CATextLayer * titleBlock;
	CATextLayer * locationBlock; // if applicable
	CATextLayer * timeBlock; // if applicable
	CATextLayer * descriptionBlock;
	
	
	NSString * churchName;
	NSImage * logoImage;
	NSColor * backgroundColor;
	
}

- (CGColorSpaceRef)genericRGBSpace;
- (CGColorRef)white;


- (void)setChurchName:(NSString *)aString;
- (void)setLogoImage:(NSImage *)anImage;
- (void)setBackgroundColor:(NSColor *)aColor;

- (void)showWindow;
- (void)showLogo;
- (void)displaySlide:(NSMutableDictionary *)slide;
- (void)hideContentElements;
- (void)hideAllElements;
- (void)reset;

- (void)setAnnouncements:(NSMutableArray *)newAnnouncements;
- (void)setCalendars:(NSMutableArray *)newEvents;


@end
