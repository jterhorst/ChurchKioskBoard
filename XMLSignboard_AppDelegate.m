//
//  XMLSignboard_AppDelegate.m
//  XMLSignboard
//
//  Created by Jason Terhorst on 10/27/08.
//  Copyright Jason Terhorst 2008 . All rights reserved.
//

#import "XMLSignboard_AppDelegate.h"

@implementation XMLSignboard_AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	NSArray * calendars = [[CalCalendarStore defaultCalendarStore] calendars];
	//NSLog(@"%d calendars", [calendars count]);
	
	calendarObjects = [NSMutableArray array];
	[calendarObjects retain];
	
	events = [[NSMutableArray alloc] init];
	announcements = [[NSMutableArray alloc] init];
	
	NSURL * feedsourceurl = [NSURL fileURLWithPath: [[self applicationSupportFolder] stringByAppendingPathComponent: @"feedsourceurl.data"]];
	if ([[NSFileManager defaultManager] fileExistsAtPath:[feedsourceurl path]])
		[xmlSourceField setStringValue:[NSString stringWithContentsOfURL:feedsourceurl]];
	
	NSURL * calendarPrefsURL = [NSURL fileURLWithPath: [[self applicationSupportFolder] stringByAppendingPathComponent: @"calendars.data"]];
	if ([[NSFileManager defaultManager] fileExistsAtPath:[calendarPrefsURL path]])
		calendarObjects = [[NSMutableArray alloc] initWithContentsOfURL:calendarPrefsURL];
	
	for (NSMutableDictionary * calendarItem in calendarObjects) {
		if ([[CalCalendarStore defaultCalendarStore] calendarWithUID:[calendarItem valueForKey:@"uid"]] == nil)
			[calendarObjects removeObject:calendarItem];
	}
	
	for (CalCalendar * calendar in calendars) {
		NSMutableDictionary * calendarItem = [NSMutableDictionary dictionary];
		[calendarItem setObject:[calendar title] forKey:@"name"];
		[calendarItem setObject:[calendar uid] forKey:@"uid"];
		[calendarItem setObject:[NSNumber numberWithBool:NO] forKey:@"active"];
		BOOL isCopy = NO;
		for (NSMutableDictionary * existingItem in calendarObjects) {
			if ([[existingItem valueForKey:@"uid"] isEqualToString:[calendarItem valueForKey:@"uid"]])
				isCopy = YES;
		}
		if (isCopy != YES)
			[calendarObjects addObject:calendarItem];
	}
	
}

- (void)awakeFromNib
{
	[calendarTableView reloadData];
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{
	[calendarTableView reloadData];
}



/**
    Returns the support folder for the application, used to store the Core Data
    store file.  This code uses a folder named "XMLSignboard" for
    the content, either in the NSApplicationSupportDirectory location or (if the
    former cannot be found), the system's temporary directory.
 */

- (NSString *)applicationSupportFolder {

    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString * basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"XMLSignboard"];
}

- (void)loadXMLFile
{
	NSURL * fileLocation;
	if (![[xmlSourceField stringValue] isEqualToString:@""] && [xmlSourceField stringValue] != nil)
		fileLocation = [NSURL URLWithString:[xmlSourceField stringValue]];
	else
		fileLocation = [NSURL URLWithString:@"http://www.jterhorst.com/announcementstest.xml"];
	
	NSURL * localFile = [NSURL fileURLWithPath: [[self applicationSupportFolder] stringByAppendingPathComponent: @"announcements.xml"]];
	
	NSError * error = nil;
	NSXMLDocument * announcementsXML = [[NSXMLDocument alloc] initWithContentsOfURL:fileLocation options:NSXMLDocumentTidyXML error:&error];
	
	if (announcementsXML != nil && error == nil) {
		
		int count = [[[announcementsXML rootElement] children] count];
		if (count > 0) {
			NSLog(@"there are internet announcements");
			for (int x = 0;x < count;x++) {
				NSXMLElement * entry = [[[announcementsXML rootElement] elementsForName:@"entry"] objectAtIndex:x];
				
				NSLog([[[entry elementsForName:@"title"] lastObject] stringValue]);
				
				//if ([[NSDate dateWithString:[[[entry elementsForName:@"startdate"] lastObject] stringValue]] timeIntervalSinceNow] < 0 && [[NSDate dateWithString:[[[entry elementsForName:@"enddate"] lastObject] stringValue]] timeIntervalSinceNow] > 0) {
					NSMutableDictionary * newAnnouncement = [NSMutableDictionary dictionary];
					[newAnnouncement setObject:[[[entry elementsForName:@"title"] lastObject] stringValue] forKey:@"title"];
					[newAnnouncement setObject:[[[entry elementsForName:@"body"] lastObject] stringValue] forKey:@"body"];
					[newAnnouncement setObject:[NSDate dateWithString:[[[entry elementsForName:@"startdate"] lastObject] stringValue]] forKey:@"startdate"];
					[newAnnouncement setObject:[NSDate dateWithString:[[[entry elementsForName:@"enddate"] lastObject] stringValue]] forKey:@"enddate"];
					
					NSLog(@"adding: %@; %@", [[[entry elementsForName:@"title"] lastObject] stringValue], [[[entry elementsForName:@"body"] lastObject] stringValue]);
					
					[announcements addObject:newAnnouncement];
				//}
				
			}
		}
		
		NSString * savedFileData = [[NSString alloc] initWithContentsOfURL:fileLocation  encoding:NSUTF8StringEncoding error:nil];
		[savedFileData writeToURL:localFile atomically:YES encoding:NSUTF8StringEncoding error:nil];
		
	} else {
		
		if ([[NSFileManager defaultManager] fileExistsAtPath:[localFile path]]) {
			
			NSString * savedFileData = [[NSString alloc] initWithContentsOfURL:localFile  encoding:NSUTF8StringEncoding error:nil];
			NSXMLDocument * announcementsXML = [[NSXMLDocument alloc] initWithXMLString:savedFileData options:NSXMLDocumentTidyXML error:nil];
			
			int count = [[[announcementsXML rootElement] children] count];
			if (count > 0) {
				NSLog(@"there are local announcements");
				for (int x = 0;x < count;x++) {
					NSXMLElement * entry = [[[announcementsXML rootElement] elementsForName:@"entry"] objectAtIndex:x];
					
					//if ([[NSDate dateWithString:[[[entry elementsForName:@"startdate"] lastObject] stringValue]] timeIntervalSinceNow] < 0 && [[NSDate dateWithString:[[[entry elementsForName:@"enddate"] lastObject] stringValue]] timeIntervalSinceNow] > 0) {
						NSMutableDictionary * newAnnouncement = [NSMutableDictionary dictionary];
						[newAnnouncement setObject:[[[entry elementsForName:@"title"] lastObject] stringValue] forKey:@"title"];
						[newAnnouncement setObject:[[[entry elementsForName:@"body"] lastObject] stringValue] forKey:@"body"];
						[newAnnouncement setObject:[NSDate dateWithString:[[[entry elementsForName:@"startdate"] lastObject] stringValue]] forKey:@"startdate"];
						[newAnnouncement setObject:[NSDate dateWithString:[[[entry elementsForName:@"enddate"] lastObject] stringValue]] forKey:@"enddate"];
						
						[announcements addObject:newAnnouncement];
					//}
					
				}
			}
			
		}
	}
	
	[newDisplay setAnnouncements:announcements];
	
	[newDisplay showWindow];
	
	if (xmlUpdateTimer == nil)
		xmlUpdateTimer = [[NSTimer scheduledTimerWithTimeInterval:3600 target:self selector:@selector(updateData:) userInfo:nil repeats:YES] retain];
}

- (void)updateData:(NSTimer *)timer
{
	NSLog(@"updating...");
	
	[self loadXMLFile];
	[self loadCalendars];
	
	if (newDisplay != nil) {
		[newDisplay setAnnouncements:announcements];
		[newDisplay setCalendars:events];
		
		[newDisplay reset];
	}
}



- (void)loadCalendars
{
	/*
	for (CalCalendar * calendar in [[CalCalendarStore defaultCalendarStore] calendars]) {
		NSLog(@"calendar: %@, uid: %@", [calendar title], [calendar uid]);
	}
	*/
	float today = [[NSCalendarDate calendarDate] dayOfWeek];
	float sunday = today * -1;
	float nextSunday = sunday + 7;
	float hourChange = [[NSCalendarDate calendarDate] hourOfDay] * -1;
	float minuteChange = [[NSCalendarDate calendarDate] minuteOfHour] * -1;
	float secondChange = [[NSCalendarDate calendarDate] secondOfMinute] * -1;
	
	// Create a predicate to fetch all events for this week
	
	NSCalendarDate * startDate = [[NSCalendarDate calendarDate] dateByAddingYears:0 months:0 days:sunday hours:hourChange minutes:minuteChange seconds:secondChange];//[[NSCalendarDate dateWithYear:year month:1 day:1 hour:0 minute:0 second:0 timeZone:nil] retain];
	NSCalendarDate * endDate = [[NSCalendarDate calendarDate] dateByAddingYears:0 months:0 days:nextSunday hours:hourChange minutes:minuteChange seconds:secondChange];//[[NSCalendarDate dateWithYear:year month:12 day:31 hour:23 minute:59 second:59 timeZone:nil] retain];
	
	NSMutableArray * calendars = [NSMutableArray array];
	for (NSMutableDictionary * calendarItem in calendarObjects) {
		if ([[calendarItem valueForKey:@"active"] boolValue])
			[calendars addObject:[[CalCalendarStore defaultCalendarStore] calendarWithUID:[calendarItem valueForKey:@"uid"]]];
	}
	
	NSPredicate * eventsForThisYear = [CalCalendarStore eventPredicateWithStartDate:startDate endDate:endDate calendars:calendars];
	
	// Fetch all events for this week
	NSArray * calEvents = [[CalCalendarStore defaultCalendarStore] eventsWithPredicate:eventsForThisYear];
	for (CalEvent * event in calEvents) {
		NSLog(@"event: %@", [event title]);
		NSMutableDictionary * newEventObject = [NSMutableDictionary dictionary];
		[newEventObject setObject:[event title] forKey:@"title"];
		if ([event location] != nil)
			[newEventObject setObject:[event location] forKey:@"location"];
		[newEventObject setObject:[event startDate] forKey:@"startDate"];
		[newEventObject setObject:[event endDate] forKey:@"endDate"];
		[events addObject:newEventObject];
	}
	
	NSLog(@"%d events", [events count]);
	
	[newDisplay setCalendars:events];
	
}




- (IBAction)changeLogo:(id)sender;
{
	NSOpenPanel * panel = [NSOpenPanel openPanel];
	
	[panel beginSheetForDirectory:nil
							   file:nil
							  types:[NSArray arrayWithObjects:@"png",nil]
					 modalForWindow:window
					  modalDelegate:self
					 didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:)
						contextInfo:nil];
}

- (void)openPanelDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if (returnCode == NSOKButton)
	{
		NSString * selectedFile = [panel filename];
		//open files here
		NSLog(@"selected file: %@", selectedFile);	
		
		
		logoImage = [[NSImage alloc] initWithContentsOfFile:selectedFile];
		if (logoImage != nil)
			NSLog(@"logo image applied succesfully");
	}

	//[panel release];
}



- (IBAction)changeBackgroundColor:(id)sender;
{
	backgroundColor = [[sender color] retain];
}





- (IBAction)startShow:(id)sender
{
	NSLog(@"starting show");
	
	newDisplay = [[SignDisplayController alloc] init];
	
	if ([[churchNameField stringValue] length] > 0)
		[newDisplay setChurchName:[churchNameField stringValue]];
	[newDisplay setBackgroundColor:[backgroundColorWell color]];
	if (logoImage != nil)
		[newDisplay setLogoImage:logoImage];
	
	[self loadXMLFile];
	[self loadCalendars];
	
}


- (IBAction)resetSettings:(id)sender
{
	[xmlSourceField setStringValue:@""];
	
	for (NSMutableDictionary * calendarItem in calendarObjects) {
		[calendarItem setObject:[NSNumber numberWithBool:NO] forKey:@"active"];
	}
	
	[calendarTableView reloadData];
}

- (IBAction)quitNow:(id)sender
{
	[[NSApplication sharedApplication] terminate:sender];
}




- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [calendarObjects count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	if ([[aTableColumn identifier] isEqualToString:@"name"])
		return [[calendarObjects objectAtIndex:rowIndex] valueForKey:@"name"];
	else if ([[aTableColumn identifier] isEqualToString:@"checked"])
		return [[calendarObjects objectAtIndex:rowIndex] valueForKey:@"active"];
	
	return nil;
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	if ([[aTableColumn identifier] isEqualToString:@"checked"])
		[[calendarObjects objectAtIndex:rowIndex] setObject:anObject forKey:@"active"];
}




- (void)applicationShouldTerminate:(NSNotification *)aNotification
{
	// if we need to save any data before quitting, this is a good place to do so...
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:[self applicationSupportFolder]])
		[[NSFileManager defaultManager] createDirectoryAtPath:[self applicationSupportFolder] attributes:nil];
	
	NSError * feedSaveError = nil;
	NSURL * feedsourceurl = [NSURL fileURLWithPath: [[self applicationSupportFolder] stringByAppendingPathComponent: @"feedsourceurl.data"]];
	if ([xmlSourceField stringValue] != nil) {
		if ([[NSFileManager defaultManager] fileExistsAtPath:[feedsourceurl path]])
			[[NSFileManager defaultManager] removeItemAtPath:[feedsourceurl path] error:nil];
		
		[[xmlSourceField stringValue] writeToURL:feedsourceurl atomically:YES encoding:NSUTF8StringEncoding error:&feedSaveError];
	}
	if (feedSaveError != nil)
		NSLog([feedSaveError localizedDescription]);
	
	NSLog([xmlSourceField stringValue]);
	
	NSURL * calendarPrefsURL = [NSURL fileURLWithPath: [[self applicationSupportFolder] stringByAppendingPathComponent: @"calendars.data"]];
	if ([calendarObjects count] > 0 && calendarObjects != nil)
		[calendarObjects writeToURL:calendarPrefsURL atomically:YES];
	
	
	
}


/**
    Implementation of dealloc, to release the retained variables.
 */
 
- (void) dealloc {

    [super dealloc];
}


@end
