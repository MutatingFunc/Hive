//
//  Toggle.swift
//  HiveShared
//
//  Created by James Froggatt on 11.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import Foundation
import Intents

public struct Toggle {
	var api: APIManaging, sessionID: SessionID
	public internal(set) var settingsManager: SettingsManaging, device: ToggleableDevice
	public init(api: APIManaging = apiManager, settingsManager: SettingsManaging = SettingsManager(), sessionID: SessionID, device: ToggleableDevice) {
		self.api = api; self.settingsManager = settingsManager; self.sessionID = sessionID; self.device = device
	}
	
	public mutating func setOn(_ isOn: Bool, completion: @escaping () -> ()) -> Progress {
		self.device.isOn = isOn
		donateIntent(isOn: isOn)
		return api.setOn(of: self.device, sessionID: self.sessionID, completion: completion)
	}
	
	func donateIntent(isOn: Bool) {
		let intent = ToggleLightIntent()
		intent.lightName = device.name
		intent.state = isOn ? .on : .off
		let interation = INInteraction(intent: intent, response: nil)
		interation.donate {error in
			if let error = error {
				print("Error donating intent: \(error)")
			}
		}
		//INRelevantShortcut for Siri watchface
	}
}
