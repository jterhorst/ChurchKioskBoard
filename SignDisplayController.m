//
//  SignDisplayController.m
//  XMLSignboard
//
//  Created by Jason Terhorst on 11/7/08.
//  Copyright 2008 Jason Terhorst. All rights reserved.
//

#import "SignDisplayController.h"


@implementation SignDisplayController

- (id)init
{
	if (self = [super init]) {
		
		NSImage* someImage = [NSImage imageNamed:@"fc_logo.png"];
				
		[self setLogoImage:someImage];
		[self setChurchName:@"First Covenant"];
		[self setBackgroundColor:[NSColor colorWithDeviceRed:0 green:0.2 blue:0.4 alpha:1.0]];
		
	}
	
	return self;
}


- (void)setChurchName:(NSString *)aString;
{
	[churchName release];
	churchName = [aString retain];
}

- (void)setLogoImage:(NSImage *)anImage;
{
	[logoImage release];
	logoImage = [anImage retain];
	
	CGContextRef bitmapCtx = CGBitmapContextCreate(NULL/*data - pass NULL to let CG allocate the memory*/, 
													   512,  
													   512, 
													   8 /*bitsPerComponent*/, 
													   0 /*bytesPerRow - CG will calculate it for you if it's allocating the data.  This might get padded out a bit for better alignment*/, 
													   [self genericRGBSpace], 
													   kCGBitmapByteOrder32Host|kCGImageAlphaPremultipliedFirst);
		
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:bitmapCtx flipped:NO]];
	[logoImage drawInRect:NSMakeRect(0,0, 512, 512) fromRect:NSZeroRect/*sentinel, means "the whole thing*/ operation:NSCompositeCopy fraction:1.0];
	[NSGraphicsContext restoreGraphicsState];
	
	logoImageRef = CGBitmapContextCreateImage(bitmapCtx);
	CFRelease(bitmapCtx);
	
}

- (void)setBackgroundColor:(NSColor *)aColor;
{
	[backgroundColor release];
	backgroundColor = [aColor retain];
}


- (void)showWindow
{
	
	if (presentationWindow == nil) {
		if ([[NSScreen screens] count] < 2)
			presentationWindow = [[FullScreenWindow alloc] initWithContentRect:[[[NSScreen screens] objectAtIndex:0] frame] styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
		else
			presentationWindow = [[FullScreenWindow alloc] initWithContentRect:[[[NSScreen screens] objectAtIndex:1] frame] styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
		
		[presentationWindow setLevel:NSStatusWindowLevel];
		[NSCursor setHiddenUntilMouseMoves:YES];
		
		presentationView = [[SignView alloc] initWithFrame:[[presentationWindow contentView] bounds]];
		[[presentationWindow contentView] addSubview:presentationView];
		[presentationWindow setHasShadow:NO];
		[presentationWindow setBackgroundColor:backgroundColor];
		[presentationView release];
		
		[presentationView setWantsLayer:YES];
		
		selectedSlide = nil;
		
		[self showLogo];
		
	}
	
	[presentationWindow makeKeyAndOrderFront:self];
	
	if (nextPageTimer == nil)
		nextPageTimer = [[NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(nextPageTimerFired:) userInfo:nil repeats:YES] retain];
	
	if (clock == nil)
		clockTimer = [[NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(setClockTime:) userInfo:nil repeats:YES] retain];
}

- (void)showLogo
{
	NSLog(@"displaying logo");
	
	if (logoImageLayer == nil) {
		logoImageLayer = [CALayer layer];
		logoImageLayer.contents = logoImageRef;
		logoImageLayer.name = @"logo";
		[logoImageLayer setOpacity:0.0];
		[logoImageLayer setFrame:CGRectMake((presentationView.frame.size.width / 2) - 256, (presentationView.frame.size.height / 2) - 256, 512, 512)];
		[presentationView.layer addSublayer:logoImageLayer];
	}
	
	logoImageLayer.opacity = 0.2;
	
	CABasicAnimation * logoZoomAnimation = [CABasicAnimation animationWithKeyPath:@"bounds.size"];
	CGSize logoSize = logoImageLayer.bounds.size;
	logoSize.width = logoSize.width * 1.1;
	logoSize.height = logoSize.height * 1.1;
	NSLog(@"size: %f by %f", logoSize.width, logoSize.height);
	NSValue * logoZoomNewValue = [NSValue valueWithSize:NSSizeFromCGSize(logoSize)];
	logoZoomAnimation.toValue = logoZoomNewValue;
	logoZoomAnimation.duration = 10;
	[logoImageLayer addAnimation:logoZoomAnimation forKey:nil];
	//[logoTitleLayer setValue:value forKeyPath:@"bounds.size"];
	
	
	
	
	if (logoTitleLayer == nil) {
		CGFloat fontSize = 48.0f;
		NSFont * font = [NSFont fontWithName:@"Georgia" size:fontSize];
		
		logoTitleLayer = [CATextLayer layer];
		logoTitleLayer.string = [NSString stringWithFormat:@"welcome to\n%@", churchName];
		logoTitleLayer.font = font;
		logoTitleLayer.fontSize = fontSize;
		logoTitleLayer.name = @"logoTitle";
		[logoTitleLayer setForegroundColor:[self white]];
		[logoTitleLayer setAlignmentMode: kCAAlignmentCenter];
		logoTitleLayer.frame = CGRectMake(0, (presentationView.frame.size.height / 2) - 75, presentationView.frame.size.width, 150);
		logoTitleLayer.opacity = 0.0;
		[presentationView.layer addSublayer:logoTitleLayer];
	}
	
	logoTitleLayer.opacity = 1.0;
	
	
}

- (void)displaySlide:(NSMutableDictionary *)slide
{
	
	CGFloat fontSize = 36.0f;
	NSFont * font = [NSFont fontWithName:@"Helvetica Neue Light" size:fontSize];
	
	if (leftHeaderBlock == nil)
	{
		leftHeaderBlock = [CATextLayer layer];
		leftHeaderBlock.string = @"header";
		leftHeaderBlock.font = [NSFont fontWithName:@"Helvetica Neue" size:fontSize];
		leftHeaderBlock.fontSize = fontSize;
		leftHeaderBlock.name = @"leftHeader";
		[leftHeaderBlock setForegroundColor:[self lightGray]];
		[leftHeaderBlock setAlignmentMode: kCAAlignmentLeft];
		leftHeaderBlock.frame = CGRectMake(10, presentationView.frame.size.height - 60, (presentationView.frame.size.width / 2) - 20, 50);
		leftHeaderBlock.opacity = 0.0;
		[presentationView.layer addSublayer:leftHeaderBlock];
	}
	
	if (clock == nil) {
		clock = [CATextLayer layer];
		clock.string = @"clock";
		clock.font = font;
		clock.fontSize = fontSize;
		clock.name = @"leftHeader";
		[clock setForegroundColor:[self lightGray]];
		[clock setAlignmentMode: kCAAlignmentRight];
		clock.frame = CGRectMake((presentationView.frame.size.width / 2) + 10, presentationView.frame.size.height - 60, (presentationView.frame.size.width / 2) - 20, 50);
		//clock.opacity = 0.0;
		[presentationView.layer addSublayer:clock];
	}
	
	clock.opacity = 1.0;
	
	// check header layers; populate, if needed, with the appropriate title
	if ([announcements indexOfObject:selectedSlide] == 0) {
		leftHeaderBlock.string = @"Announcements";
	} else if ([events indexOfObject:selectedSlide] == 0) {
		leftHeaderBlock.string = [NSString stringWithFormat:@"This week at %@", churchName];
	}
	
	leftHeaderBlock.opacity = 1.0;
	
	// showContent
	
	if (titleBlock == nil)
	{
		titleBlock = [CATextLayer layer];
		titleBlock.string = @"title";
		titleBlock.font = [NSFont fontWithName:@"Helvetica Neue Bold" size:fontSize];
		titleBlock.fontSize = fontSize;
		titleBlock.wrapped = YES;
		titleBlock.name = @"leftHeader";
		[titleBlock setForegroundColor:[self white]];
		[titleBlock setAlignmentMode: kCAAlignmentLeft];
		titleBlock.frame = CGRectMake(10, 90, presentationView.frame.size.width - 20, presentationView.frame.size.height - 190);
		//descriptionBlock.opacity = 0.0;
		[presentationView.layer addSublayer:titleBlock];
	}
	
	if ([slide valueForKey:@"title"] != nil) {
		titleBlock.string = [slide valueForKey:@"title"];
	} else if ([slide valueForKey:@"name"] != nil) {
		titleBlock.string = [slide valueForKey:@"name"];
	} else {
		titleBlock.string = @"";
	}
	
	titleBlock.opacity = 1.0;
	

	
	if (descriptionBlock == nil)
	{
		descriptionBlock = [CATextLayer layer];
		descriptionBlock.string = @"description";
		descriptionBlock.font = font;
		descriptionBlock.fontSize = fontSize;
		descriptionBlock.wrapped = YES;
		descriptionBlock.name = @"leftHeader";
		[descriptionBlock setForegroundColor:[self white]];
		[descriptionBlock setAlignmentMode: kCAAlignmentLeft];
		descriptionBlock.frame = CGRectMake(10, 90, presentationView.frame.size.width - 20, presentationView.frame.size.height - 250);
		//descriptionBlock.opacity = 0.0;
		[presentationView.layer addSublayer:descriptionBlock];
	}
	
	if ([slide valueForKey:@"body"] != nil) {
		descriptionBlock.string = [slide valueForKey:@"body"];
	} else {
		descriptionBlock.string = @"";
	}
	
	descriptionBlock.opacity = 1.0;
	
	
	if (locationBlock == nil)
	{
		locationBlock = [CATextLayer layer];
		locationBlock.string = @"location";
		locationBlock.font = font;
		locationBlock.fontSize = fontSize;
		locationBlock.wrapped = YES;
		locationBlock.name = @"leftHeader";
		[locationBlock setForegroundColor:[self white]];
		[locationBlock setAlignmentMode: kCAAlignmentLeft];
		locationBlock.frame = CGRectMake(10, 90, presentationView.frame.size.width - 20, presentationView.frame.size.height - 250);
		//descriptionBlock.opacity = 0.0;
		[presentationView.layer addSublayer:locationBlock];
	}
	
	if ([slide valueForKey:@"location"] != nil) {
		locationBlock.string = [slide valueForKey:@"location"];
	} else {
		locationBlock.string = @"";
	}
	
	locationBlock.opacity = 1.0;
	
	
	
	if (timeBlock == nil)
	{
		timeBlock = [CATextLayer layer];
		timeBlock.string = @"time";
		timeBlock.font = font;
		timeBlock.fontSize = fontSize;
		timeBlock.wrapped = YES;
		timeBlock.name = @"leftHeader";
		[timeBlock setForegroundColor:[self white]];
		[timeBlock setAlignmentMode: kCAAlignmentLeft];
		timeBlock.frame = CGRectMake(10, 90, presentationView.frame.size.width - 20, presentationView.frame.size.height - 250);
		//descriptionBlock.opacity = 0.0;
		[presentationView.layer addSublayer:timeBlock];
	}
	
	if ([slide valueForKey:@"startDate"] != nil) {
		timeBlock.string = [[[slide valueForKey:@"startDate"] descriptionWithCalendarFormat:@"%B %e, %I:%M %p to " timeZone:nil locale:nil] stringByAppendingString:[[slide valueForKey:@"endDate"] descriptionWithCalendarFormat:@"%I:%M %p" timeZone:nil locale:nil]];
	} else {
		timeBlock.string = @"";
	}
	
	timeBlock.opacity = 1.0;
	
	
	
}

- (void)setClockTime:(NSTimer *)timer
{
	NSCalendarDate *now = [NSCalendarDate calendarDate];
	NSString *nowAsString =
    [now descriptionWithCalendarFormat:@"%a, %b %e, %I:%M:%S %p"];
	
	if (clock != nil)
		clock.string = nowAsString;
}

- (void)hideContentElements
{
	// clear contentLayers array (remove from parent layer, and dump from array); don't touch the headerLayers array
	
	
	if (locationBlock.opacity > 0) {
		CABasicAnimation * anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
		//anim.delegate = self; //to get the animationDidStop:finished: message
		anim.toValue = [NSNumber numberWithFloat:0.0];
		anim.duration = 1.0;
		[locationBlock addAnimation:anim forKey:@"fadeOutAnimation"];
		locationBlock.opacity = 0;
	}
	
	if (timeBlock.opacity > 0) {
		CABasicAnimation * anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
		//anim.delegate = self; //to get the animationDidStop:finished: message
		anim.toValue = [NSNumber numberWithFloat:0.0];
		anim.duration = 1.0;
		[timeBlock addAnimation:anim forKey:@"fadeOutAnimation"];
		timeBlock.opacity = 0;
	}
	
	if (titleBlock.opacity > 0) {
		CABasicAnimation * anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
		anim.delegate = self; //to get the animationDidStop:finished: message
		anim.toValue = [NSNumber numberWithFloat:0.0];
		anim.duration = 1.0;
		[titleBlock addAnimation:anim forKey:@"fadeOutAnimation"];
		titleBlock.opacity = 0;
	}
	
	if (locationBlock.opacity > 0) {
		CABasicAnimation * anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
		//anim.delegate = self; //to get the animationDidStop:finished: message
		anim.toValue = [NSNumber numberWithFloat:0.0];
		anim.duration = 1.0;
		[locationBlock addAnimation:anim forKey:@"fadeOutAnimation"];
		locationBlock.opacity = 0;
	}
	
	if (descriptionBlock.opacity > 0) {
		CABasicAnimation * anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
		anim.delegate = self; //to get the animationDidStop:finished: message
		anim.toValue = [NSNumber numberWithFloat:0.0];
		anim.duration = 1.0;
		[descriptionBlock addAnimation:anim forKey:@"fadeOutAnimation"];
		descriptionBlock.opacity = 0;
	}
	
}

- (void)hideAllElements
{
	// clear logoLayers, contentLayers, and headerLayers (iterate, removing from parent layer, and dump from array, before continuing)
	
	NSLog(@"hiding elements...");
	
	if (logoTitleLayer.opacity > 0) {
		CABasicAnimation * anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
		anim.delegate = self; //to get the animationDidStop:finished: message
		anim.toValue = [NSNumber numberWithFloat:0.0];
		anim.duration = 1.0;
		[logoTitleLayer addAnimation:anim forKey:@"fadeOutAnimation"];
		logoTitleLayer.opacity = 0;
		[logoImageLayer addAnimation:anim forKey:@"fadeOutAnimation"];
		logoImageLayer.opacity = 0;
	}
	
	if (leftHeaderBlock.opacity > 0) {
		CABasicAnimation * anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
		//anim.delegate = self; //to get the animationDidStop:finished: message
		anim.toValue = [NSNumber numberWithFloat:0.0];
		anim.duration = 1.0;
		[leftHeaderBlock addAnimation:anim forKey:@"fadeOutAnimation"];
		leftHeaderBlock.opacity = 0;
	}
	
	if (clock.opacity > 0) {
		CABasicAnimation * anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
		anim.delegate = self; //to get the animationDidStop:finished: message
		anim.toValue = [NSNumber numberWithFloat:0.0];
		anim.duration = 1.0;
		[clock addAnimation:anim forKey:@"fadeOutAnimation"];
		clock.opacity = 0;
	}
	
	
	/*
	for (CALayer * someLayer in logoLayers) {
		CABasicAnimation * anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
		anim.delegate = self; //to get the animationDidStop:finished: message
		anim.fromValue = [NSNumber numberWithFloat:1.0];
		anim.toValue = [NSNumber numberWithFloat:0.0];
		[someLayer addAnimation:anim forKey:@"fadeOutAnimation"];
		someLayer.opacity = 0;
		NSLog(@"fading out %@", [someLayer name]);
	}
	
	for (CALayer * someLayer in contentLayers) {
		CABasicAnimation * anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
		anim.delegate = self; //to get the animationDidStop:finished: message
		anim.fromValue = [NSNumber numberWithFloat:1.0];
		anim.toValue = [NSNumber numberWithFloat:0.0];
		[someLayer addAnimation:anim forKey:@"fadeOutAnimation"];
		someLayer.opacity = 0;
		NSLog(@"fading out %@", [someLayer name]);
	}
	
	for (CALayer * someLayer in headerLayers) {
		CABasicAnimation * anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
		anim.delegate = self; //to get the animationDidStop:finished: message
		anim.fromValue = [NSNumber numberWithFloat:1.0];
		anim.toValue = [NSNumber numberWithFloat:0.0];
		[someLayer addAnimation:anim forKey:@"fadeOutAnimation"];
		someLayer.opacity = 0;
		NSLog(@"fading out %@", [someLayer name]);
	}
	*/
	
	[self hideContentElements];
}

- (void)nextPageTimerFired:(NSTimer *)timer
{
	NSLog(@"next page");
	
	// this signifies that the previous one is done, so we fade it out, and prepare for the next one.
	// fade out here, fade in with animationDidStop:finished: below
	
	// here, create the animations (to remove content), and set ourself as delegate, so that we know when to continue on...
	// set selectedSlide to the next page
	
	
	if (selectedSlide == nil) {
		// start with announcements after showing logo
		
		[self hideAllElements];
		
		if ([announcements count] > 0)
			selectedSlide = [announcements objectAtIndex:0];
		else if ([events count] > 0)
			selectedSlide = [events objectAtIndex:0];
		
	} else if ([events containsObject:selectedSlide]) {
		// next event... if none, go to logo
		
		int itemNumber = [events indexOfObject:selectedSlide];
		
		if (itemNumber < [events count] - 1) {
			[self hideContentElements];
			selectedSlide = [events objectAtIndex:itemNumber + 1];
		} else {
			[self hideAllElements];
			selectedSlide = nil;
		}
		
	} else if ([announcements containsObject:selectedSlide]) {
		// next announcment... if none, go to events
		
		int itemNumber = [announcements indexOfObject:selectedSlide];
		
		if (itemNumber < [announcements count] - 1) {
			[self hideContentElements];
			selectedSlide = [announcements objectAtIndex:itemNumber + 1];
		} else {
			[self hideAllElements];
			if ([events count] > 0)
				selectedSlide = [events objectAtIndex:0];
			else
				selectedSlide = nil;
		}
	}
}

- (void)reset
{
	NSLog(@"resetting");
	
	selectedSlide = nil;
	
	[self nextPageTimerFired:nil];
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
	if (flag == NO)
		return;
	/*
	for (CALayer * someLayer in logoLayers) {
		if ([[someLayer animationForKey:@"fadeOutAnimation"] isEqual:theAnimation]) {
			someLayer.opacity = 0;
			[someLayer removeFromSuperlayer];
			[logoLayers removeObject:someLayer];
		}
	}
	
	for (CALayer * someLayer in contentLayers) {
		if ([[someLayer animationForKey:@"fadeOutAnimation"] isEqual:theAnimation]) {
			someLayer.opacity = 0;
			[someLayer removeFromSuperlayer];
			[logoLayers removeObject:someLayer];
		}
	}
	*/
	 
	if (selectedSlide == nil) {
		/*
		for (CALayer * someLayer in headerLayers) {
			if ([[someLayer animationForKey:@"fadeOutAnimation"] isEqual:theAnimation]) {
				someLayer.opacity = 0;
				[someLayer removeFromSuperlayer];
				[logoLayers removeObject:someLayer];
			}
		}
		*/
		 
		// show logo
		[self showLogo];
		
	} else {
		
		// figure out what data is here, and display it, along with headers, logo, etc.
		if ([announcements indexOfObject:selectedSlide] == 0) {
			
			// clear out existing
			/*
			for (CALayer * someLayer in headerLayers) {
				if ([[someLayer animationForKey:@"fadeOutAnimation"] isEqual:theAnimation]) {
					someLayer.opacity = 0;
					[someLayer removeFromSuperlayer];
					[logoLayers removeObject:someLayer];
				}
			}
			 */
			
		}
		
		[self displaySlide:selectedSlide];
	}
	 
	 
}



- (void)pushForward
{
	CATextLayer * titleLayer = [[presentationView.layer sublayers] objectAtIndex:0];
	CATextLayer * bodyLayer = [[presentationView.layer sublayers] objectAtIndex:1];
	
	CGSize bodyPreferredSize = CGSizeMake(presentationView.layer.frame.size.width - 20, presentationView.layer.frame.size.height - 70);
	//[titleLayer setValue:[NSNumber numberWithFloat:titleLayer.fontSize * 2] forKey:@"fontSize"];
	[bodyLayer setValue:[NSValue valueWithRect:NSMakeRect(10, presentationView.layer.frame.size.height - bodyPreferredSize.height - 10, presentationView.layer.frame.size.width - 20, bodyPreferredSize.height)] forKey:@"frame"];
	[titleLayer setValue:[NSNumber numberWithFloat:0.0f] forKey:@"opacity"];
	
}

- (CGColorSpaceRef)genericRGBSpace {
	static CGColorSpaceRef space = NULL;
	if (NULL == space) {
		space = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
	}
	return space;
}

- (CGColorRef)white {
	static CGColorRef white = NULL;
	if (white == NULL) {
		CGFloat values[4] = {1.0, 1.0, 1.0, 1.0};
		white = CGColorCreate([self genericRGBSpace], values);
	}
	return white;
}

- (CGColorRef)lightGray {
	static CGColorRef lightGray = NULL;
	if (lightGray == NULL) {
		CGFloat values[4] = {1.0, 1.0, 1.0, 0.7};
		lightGray = CGColorCreate([self genericRGBSpace], values);
	}
	return lightGray;
}


- (void)setAnnouncements:(NSMutableArray *)newAnnouncements
{
	if (announcements != nil)
		[announcements release];
	announcements = [newAnnouncements retain];
	
	NSLog(@"%d announcments", [announcements count]);
}

- (void)setCalendars:(NSMutableArray *)newEvents
{
	if (events != nil)
		[events release];
	events = [newEvents retain];
	
	NSLog(@"%d events", [events count]);
}


@end
