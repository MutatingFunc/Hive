//
//  Light.swift
//  Hive
//
//  Created by James Froggatt on 04.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import Foundation

public struct Light: ViewModel {
	var api: APIManaging, sessionID: SessionID
	public internal(set) var settingsManager: SettingsManaging, device: LightDevice
	public init(api: APIManaging = apiManager, settingsManager: SettingsManaging = SettingsManager(), sessionID: SessionID, device: LightDevice) {
		self.api = api; self.settingsManager = settingsManager; self.sessionID = sessionID; self.device = device
	}
	
	public mutating func setIsOn(_ isOn: Bool, completion: @escaping (Response<()>) -> ()) -> Progress {
		return vmSetIsOn(isOn, viewModel: &self, completion: completion)
	}
	
	public mutating func setBrightness(_ brightness: Float, completion: @escaping (Response<()>) -> ()) -> Progress {
		return vmSetBrightness(brightness, viewModel: &self, completion: completion)
	}
}
