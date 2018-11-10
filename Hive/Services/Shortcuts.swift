//
//  Shortcuts.swift
//  Hive
//
//  Created by James Froggatt on 06.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import Foundation
import Intents

struct ActivityService {
	enum Action: String {
		case performAction
		case turnOnLight
	}
	
	private func activity(type: Action, deviceID: DeviceID) -> NSUserActivity {
		let activity = NSUserActivity(activityType: type.rawValue)
		activity.persistentIdentifier = "\(deviceID).\(type)"
		activity.isEligibleForSearch = true
		activity.isEligibleForHandoff = false
		activity.isEligibleForPrediction = true
		activity.requiredUserInfoKeys = [""]
		activity.userInfo = ["": deviceID.rawValue]
		return activity
	}
	func registerActivities(devices: [Device]) {
		let activities = devices.flatMap {device -> [NSUserActivity] in
			switch device {
			case is LightDevice, is ColourLightDevice:
				let activity = self.activity(type: .turnOnLight, deviceID: device.id)
				activity.keywords = ["Light", "On", "Activate", device.name]
				activity.suggestedInvocationPhrase = "Turn on \(device.name)"
				activity.title = "Turn on \(device.name)"
				return [activity]
			case is ActionDevice:
				let activity = self.activity(type: .performAction, deviceID: device.id)
				activity.keywords = ["Perform", "Run", "Activate", device.name]
				activity.suggestedInvocationPhrase = "Perform \(device.name)"
				activity.title = "Perform \(device.name)"
				return [activity]
			case _:
				return []
			}
		}
		let shortcuts = activities.map(INShortcut.init)
		INVoiceShortcutCenter.shared.setShortcutSuggestions(shortcuts)
	}
	
	func components(for activity: NSUserActivity) -> (deviceID: DeviceID, action: Action)? {
		guard
			let deviceID = (activity.userInfo?[""] as? String).map(DeviceID.init),
			let action = Action(rawValue: activity.activityType)
		else {
			return nil
		}
		return (deviceID: deviceID, action: action)
	}
}
