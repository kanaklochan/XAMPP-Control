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

#import "ProFTPDSecurityCheck.h"


@implementation ProFTPDSecurityCheck

- (id) init
{
	self = [super init];
	if (self != nil) {
		
		if (![NSBundle loadNibNamed:@"ProFTPDSecurityCheck" owner:self]) {
			[self release];
			return Nil;
		}
		
		[self setTitle:NSLocalizedString(@"Secure ProFTPD", @"The title of the Security Check ProFTPD page")];
		[self setStepTitle:NSLocalizedString(@"ProFTPD", @"The step title of the Security Check ProFTPD page which will displayed on the left side")];
		[self setType:AssistantNormalPage];
	}
	return self;
}

- (id) copyWithZone:(NSZone *)zone
{
	return [[[self class] allocWithZone:zone] init];
}

- (BOOL) valid
{
	if (changeNobodyPassword) {	
		if ([[password stringValue] length] < 6)
			return NO;
	
		if (![[password stringValue] isEqualToString:[passwordConfirm stringValue]])
			return NO;
	}
	
	return YES;
}

- (void) calcualteTasks
{
	
}

- (NSArray*) tasks
{
	return [NSArray array];
}

- (void) checkSecurity
{
	
}

- (BOOL) isSecure
{
	return NO;
}

@end
