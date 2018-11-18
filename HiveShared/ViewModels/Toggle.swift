//
//  Toggle.swift
//  HiveShared
//
//  Created by James Froggatt on 11.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import Foundation

public struct Toggle: ViewModel {
	var api: APIManaging, sessionID: SessionID
	public internal(set) var settingsManager: SettingsManaging, device: ToggleableDevice
	public init(api: APIManaging = apiManager, settingsManager: SettingsManaging = SettingsManager(), sessionID: SessionID, device: ToggleableDevice) {
		self.api = api; self.settingsManager = settingsManager; self.sessionID = sessionID; self.device = device
	}
	
	public mutating func setIsOn(_ isOn: Bool, completion: @escaping (Response<()>) -> ()) -> Progress {
		return vmSetIsOn(isOn, viewModel: &self, completion: completion)
	}
}
