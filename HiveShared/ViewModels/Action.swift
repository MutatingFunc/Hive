//
//  Action.swift
//  Hive
//
//  Created by James Froggatt on 05.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import Foundation

public struct Action: ViewModel {
	var api: APIManaging, auth: Authorization
	public internal(set) var settingsManager: SettingsManaging, device: ActionDevice
	public init(api: APIManaging = apiManager, settingsManager: SettingsManaging = SettingsManager(), auth: Authorization, device: ActionDevice) {
		self.api = api; self.settingsManager = settingsManager; self.auth = auth; self.device = device
	}

	public func quickAction(completion: @escaping (Response<()>) -> ()) -> Progress {
		donateActionIntent(device)
		return api.quickAction(device, auth: auth, completion: completion)
	}
}
