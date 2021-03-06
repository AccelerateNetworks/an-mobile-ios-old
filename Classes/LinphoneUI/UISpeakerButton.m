/*
 * Copyright (c) 2010-2020 Belledonne Communications SARL.
 *
 * This file is part of linphone-iphone
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

#import "linphoneapp-Swift.h"
#import <AudioToolbox/AudioToolbox.h>
#import "UISpeakerButton.h"
#import "Utils.h"
#import "LinphoneManager.h"

#include "linphone/linphonecore.h"

@implementation UISpeakerButton

INIT_WITH_COMMON_CF {
	[NSNotificationCenter.defaultCenter addObserver:self
										   selector:@selector(audioRouteChangeListenerCallback:)
											   name:AVAudioSessionRouteChangeNotification
											 object:nil];
	return self;
}

- (void)onOn {
	[CallManager.instance changeRouteToSpeaker];
}

- (void)onOff {
	[CallManager.instance changeRouteToDefault];
}


- (void)dealloc {
	[NSNotificationCenter.defaultCenter removeObserver:self];
}

#pragma mark - UIToggleButtonDelegate Functions

- (void)audioRouteChangeListenerCallback:(NSNotification *)notif {
	dispatch_async(dispatch_get_main_queue(), ^{
		[self update];});
}

- (bool)onUpdate {
	return [CallManager.instance isSpeakerEnabled];
}

@end
