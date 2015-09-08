/* UIHistoryCell.m
 *
 * Copyright (C) 2012  Belledonne Comunications, Grenoble, France
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Library General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */

#import "UIHistoryCell.h"
#import "LinphoneManager.h"
#import "PhoneMainView.h"
#import "Utils.h"

@implementation UIHistoryCell

@synthesize callLog;
@synthesize displayNameLabel;

#pragma mark - Lifecycle Functions

- (id)initWithIdentifier:(NSString *)identifier {
	if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier]) != nil) {
		NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"UIHistoryCell" owner:self options:nil];

		if ([arrayOfViews count] >= 1) {
			[self.contentView addSubview:[arrayOfViews objectAtIndex:0]];
		}

		self->callLog = NULL;
	}
	return self;
}

#pragma mark - Action Functions

- (void)setCallLog:(LinphoneCallLog *)acallLog {
	callLog = acallLog;
	[self update];
}

#pragma mark - Action Functions

- (IBAction)onDetails:(id)event {
	if (callLog != NULL && linphone_call_log_get_call_id(callLog) != NULL) {
		// Go to History details view
		HistoryDetailsViewController *controller = DYNAMIC_CAST(
			[[PhoneMainView instance] changeCurrentView:[HistoryDetailsViewController compositeViewDescription]
												   push:TRUE],
			HistoryDetailsViewController);
		if (controller != nil) {
			[controller setCallLogId:[NSString stringWithUTF8String:linphone_call_log_get_call_id(callLog)]];
		}
	}
}

- (IBAction)onDelete:(id)event {
	if (callLog != NULL) {
		UIView *view = [self superview];
		// Find TableViewCell
		while (view != nil && ![view isKindOfClass:[UITableView class]])
			view = [view superview];
		if (view != nil) {
			UITableView *tableView = (UITableView *)view;
			NSIndexPath *indexPath = [tableView indexPathForCell:self];
			[[tableView dataSource] tableView:tableView
						   commitEditingStyle:UITableViewCellEditingStyleDelete
							forRowAtIndexPath:indexPath];
		}
	}
}

#pragma mark -

- (NSString *)accessibilityValue {
	// TODO: localize?
	BOOL incoming = linphone_call_log_get_dir(callLog) == LinphoneCallIncoming;
	BOOL missed = linphone_call_log_get_status(callLog) == LinphoneCallMissed;

	NSString *call_type = @"Outgoing";
	if (incoming) {
		call_type = missed ? @"Missed" : @"Incoming";
	}

	return [NSString stringWithFormat:@"%@ from %@", call_type, displayNameLabel.text];
}

- (void)update {
	if (callLog == NULL) {
		LOGW(@"Cannot update history cell: null callLog");
		return;
	}

	// Set up the cell...
	const LinphoneAddress *addr;
	UIImage *image;
	if (linphone_call_log_get_dir(callLog) == LinphoneCallIncoming) {
		if (linphone_call_log_get_status(callLog) != LinphoneCallMissed) {
			image = [UIImage imageNamed:@"call_status_incoming.png"];
		} else {
			image = [UIImage imageNamed:@"call_status_missed.png"];
		}
		addr = linphone_call_log_get_from_address(callLog);
	} else {
		image = [UIImage imageNamed:@"call_status_outgoing.png"];
		addr = linphone_call_log_get_to_address(callLog);
	}
	_stateImage.image = image;

	[ContactDisplay setDisplayNameLabel:displayNameLabel forAddress:addr];
	ABRecordRef contact = [FastAddressBook getContactWithLinphoneAddress:addr];
	_avatarImage.image = [FastAddressBook getContactImage:contact thumbnail:TRUE];
}

- (void)setEditing:(BOOL)editing {
	[self setEditing:editing animated:FALSE];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	if (animated) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.3];
	}
#if 0
	if (editing) {
		[deleteButton setAlpha:1.0f];
		[detailsButton setAlpha:0.0f];
	} else {
		[detailsButton setAlpha:1.0f];
		[deleteButton setAlpha:0.0f];
	}
#endif
	if (animated) {
		[UIView commitAnimations];
	}
}

@end
