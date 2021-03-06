/*
 
 XAMPP
 Copyright (C) 2009 by Apache Friends
 
 Authors of this file:
 - Christian Speich <kleinweby@apachefriends.org>
 
 This file is part of XAMPP.
 
 XAMPP is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 XAMPP is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with XAMPP.  If not, see <http://www.gnu.org/licenses/>.
 
 */

#import "MySQLModule.h"

#import <XAMPP Control/XPError.h>
#import <XAMPP Control/XPRootTask.h>
#import <XAMPP Control/XPConfiguration.h>
#import <unistd.h>

@interface MySQLModule (PRIVAT)

- (NSError*) otherMySQLCheck;

@end

@implementation MySQLModule

- (id) init
{
	self = [super init];
	if (self != nil) {
		char hostname[256];
		
		gethostname(hostname, 256);
		
		[self setPidFile:[XPConfiguration fullXAMPPPathFor:[NSString stringWithFormat:@"/xamppfiles/var/mysql/%s.pid", hostname]]];
		[self setName:@"MySQL"];
	}
	return self;
}

- (NSError*) realStart
{
	XPRootTask *mysqlServer = [[XPRootTask new] autorelease];
	NSMutableDictionary* errorDict;
	NSError *error = Nil;
	
	error = [mysqlServer authorize];
	if (error)
		return error;
	
	// Fix rights if needed
	[self checkFixRightsAndRunIfNeeded];
	
	[mysqlServer setLaunchPath:[XPConfiguration fullXAMPPPathFor:@"/xamppfiles/bin/mysql.server"]];
	[mysqlServer setArguments:[NSArray arrayWithObjects:@"start", nil]];
	
	[mysqlServer setEnvironment:[NSDictionary dictionaryWithObject:@"C" forKey:@"LANG"]];
	//[mysqlServer setStandardError:standardError];
	
	[mysqlServer launch];
	[mysqlServer waitUntilExit];
	
	if ([mysqlServer terminationStatus] == 0) // Great mysql is up and running :)
		return Nil;
	
	// Hm, ok mysql didn't start :/
	errorDict = [NSMutableDictionary dictionary];
	
	[errorDict setValue:[XPConfiguration fullXAMPPPathFor:@"/xamppfiles/logs/error_log"]
				 forKey:XPErrorLogFileKey];
	[errorDict setValue:[self name] 
				 forKey:XPErrorModuleNameKey];
	
	error = [NSError errorWithDomain:XAMPPControlErrorDomain
								code:XPDidNotStart 
							userInfo:errorDict];
	
	return error;
}

- (NSError*) runStartTests
{
	NSError* error;
	
	error = [super runStartTests];
	if (error)
		return error;
	
	error = [self otherMySQLCheck];
	if (error)
		return error;
	
	return Nil;
}

- (NSError*) realStop
{
	XPRootTask *mysqlServer = [[XPRootTask new] autorelease];
	NSString *output;
	NSError *error = Nil;
	
	error = [mysqlServer authorize];
	if (error)
		return error;
	
	[mysqlServer setLaunchPath:[XPConfiguration fullXAMPPPathFor:@"/xamppfiles/bin/mysql.server"]];
	[mysqlServer setArguments:[NSArray arrayWithObjects:@"stop", nil]];
	
	[mysqlServer setEnvironment:[NSDictionary dictionaryWithObject:@"C" forKey:@"LANG"]];
	//[mysqlServer setStandardError:standardError];
	
	[mysqlServer launch];
	[mysqlServer waitUntilExit];
	
	if ([mysqlServer terminationStatus] == 0) // Great mysql has stopped :)
		return Nil;
	
	// Hm, ok mysql didn't stop?!?! :/
	output = [[[NSString alloc] initWithData:[[mysqlServer communicationsPipe] readDataToEndOfFile]
								    encoding:NSUTF8StringEncoding] autorelease];
	
	error = [NSError errorWithDomain:XAMPPControlErrorDomain 
								code:XPDidNotStop 
							userInfo:[NSDictionary dictionaryWithObject:output 
																 forKey:NSLocalizedDescriptionKey]];
	return error;
}

- (NSError*) realReload
{
	XPRootTask *kill;
	NSError *error = Nil;
	
	kill = [[XPRootTask new] autorelease];
	
	error = [kill authorize];
	if (error)
		return error;
	
	[kill setLaunchPath:@"/bin/kill"];
	[kill setArguments:[NSArray arrayWithObjects:@"-HUP", [NSString stringWithContentsOfFile:[self pidFile]], Nil]];
	
	// We don't check for success at all :)
	[kill launch];
	[kill waitUntilExit];
		
	return nil;
}

#pragma mark -
#pragma mark Priority Protocol

- (int) priority
{
	return -1000;
}

- (NSString*) comparisonString
{
	return @"MySQL";
}

@end

@implementation MySQLModule (PRIVAT)

- (NSError*) otherMySQLCheck
{
	NSError* error;
	NSMutableDictionary* errorDict;
	
	if (![[NSWorkspace sharedWorkspace] isPortInUse:3306])
		return Nil;
	
	errorDict = [NSMutableDictionary dictionary];
	
	[errorDict setValue:XPLocalizedString(@"AnotherMySQLserverError", @"Another mysql server is already running!")
				 forKey:NSLocalizedDescriptionKey];
	[errorDict setValue:XPLocalizedString(@"AnotherMySQLserverErrorDescription", @"XAMPP's MySQL can not start while another mysql server is running. Please turn it off and try again.")
				 forKey:NSLocalizedRecoverySuggestionErrorKey];
	
	error = [NSError errorWithDomain:XAMPPControlErrorDomain
								code:XPOtherServerRunning 
							userInfo:errorDict];
	
	return error;
}

@end
