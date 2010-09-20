//
//  SignView.m
//  XMLSignboard
//
//  Created by Jason Terhorst on 11/10/08.
//  Copyright 2008 Jason Terhorst. All rights reserved.
//

#import "SignView.h"


@implementation SignView


- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (void)keyDown:(NSEvent *)e
{
	/*
	// every app with eye candy needs a slow mode invoked by the shift key
	if ([e modifierFlags] & (NSAlphaShiftKeyMask|NSShiftKeyMask))
		[CATransaction setValue:[NSNumber numberWithFloat:2.0f] forKey:@"animationDuration"];
	*/
	switch ([e keyCode])
    {
		case 53:
			NSLog(@"esc key");
			[[self window] orderOut:self];
			break;
			
		default:
			NSLog (@"unhandled key event: %d\n", [e keyCode]);
			[super keyDown:e];
    }
}


@end
