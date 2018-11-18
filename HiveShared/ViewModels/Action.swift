//
//  Action.swift
//  Hive
//
//  Created by James Froggatt on 05.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import Foundation

public struct Action: ViewModel {
	var api: APIManaging, sessionID: SessionID
	public internal(set) var settingsManager: SettingsManaging, device: ActionDevice
	public init(api: APIManaging = apiManager, settingsManager: SettingsManaging = SettingsManager(), sessionID: SessionID, device: ActionDevice) {
		self.api = api; self.settingsManager = settingsManager; self.sessionID = sessionID; self.device = device
	}

	public func quickAction(completion: @escaping (Response<()>) -> ()) -> Progress {
		donateActionIntent(device)
		return api.quickAction(device, sessionID: sessionID, completion: completion)
	}
}
