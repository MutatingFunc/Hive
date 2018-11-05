//
//  Action.swift
//  Hive
//
//  Created by James Froggatt on 05.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import Foundation

struct Action {
	var api: APIManaging, sessionID: SessionID, device: ActionDevice
	init(api: APIManaging = APIManager(), sessionID: SessionID, device: ActionDevice) {
		self.api = api; self.sessionID = sessionID; self.device = device
	}

	func quickAction(completion: @escaping () -> ()) -> Progress {
		return api.quickAction(device, sessionID: sessionID, completion: completion)
	}
}
