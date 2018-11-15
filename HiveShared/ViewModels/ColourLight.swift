//
//  ColourLight.swift
//  Hive
//
//  Created by James Froggatt on 05.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import Foundation

public struct ColourLight {
	var api: APIManaging, sessionID: SessionID
	public internal(set) var settingsManager: SettingsManaging, device: ColourLightDevice
	public init(api: APIManaging = apiManager, settingsManager: SettingsManaging = SettingsManager(), sessionID: SessionID, device: ColourLightDevice) {
		self.api = api; self.settingsManager = settingsManager; self.sessionID = sessionID; self.device = device
	}
	
	public mutating func setState(_ state: ColourLightDevice.State?, completion: @escaping (Response<()>) -> ()) -> Progress {
		if let state = state {
			self.device.state = state
		}
		self.device.isOn = state != nil
		return api.updateState(of: self.device, sessionID: self.sessionID, completion: completion)
	}
}
