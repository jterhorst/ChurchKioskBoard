ChurchKioskBoard for Mac
================================

* Designed to run on an Intel-based Mac Mini with Core Animation. Geared for Snow Leopard.

Customizable
------------

You can drop in your church's name and logo, and even change the color.
Logo should be 512px square image - the logo itself should be white, with transparency, in PNG format.

Future roadmap:
---------------

* Save settings
* "Themes" and other custom designs
* Custom animation
* Support for Fellowship One and popular CMSes such as Drupal, Joomla, Wordpress, and Squarespace

iCal support
------------

On launch, choose an iCal calendar, and we'll read from the description field and day/time of events for the week. You can subscribe to Google Calendars in iCal, if you need Google Calendar automatic integration.

XML
---

Point the field to a feed on your church's web server (you can customize your CMS to output this data in the appropriate format).
The XML format is as follows:

<announcements>
	<entry>
		<title>Sample Item</title>
		<startdate>2008-10-28 11:00:00 -0500</startdate>
		<enddate>2008-11-01 11:00:00 -0500</enddate>
		<body>Here's some sample body copy.</body>
	</entry>
	<entry>
		<title>Sample Item</title>
		<startdate>2008-10-29 11:00:00 -0500</startdate>
		<enddate>2008-11-22 11:00:00 -0500</enddate>
		<body>Here's some sample body copy.</body>
	</entry>
	<entry>
		<title>Sample Item</title>
		<startdate>2009-10-29 11:00:00 -0500</startdate>
		<enddate>2009-11-13 11:00:00 -0500</enddate>
		<body>Here's some sample body copy.</body>
	</entry>
	<entry>
		<title>Sample Item</title>
		<startdate>2008-10-27 11:00:00 -0500</startdate>
		<enddate>2008-11-08 11:00:00 -0500</enddate>
		<body>Here's some sample body copy.</body>
	</entry>
</announcements>
