//
//  Action.swift
//  Hive
//
//  Created by James Froggatt on 05.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import Foundation
import Intents

public struct Action {
	var api: APIManaging, sessionID: SessionID
	public internal(set) var device: ActionDevice
	public init(api: APIManaging = APIManager(), sessionID: SessionID, device: ActionDevice) {
		self.api = api; self.sessionID = sessionID; self.device = device
	}

	public func quickAction(completion: @escaping () -> ()) -> Progress {
		donateIntent()
		return api.quickAction(device, sessionID: sessionID, completion: completion)
	}
	
	func donateIntent() {
		let intent = PerformActionIntent()
		intent.actionName = device.name
		let interation = INInteraction(intent: intent, response: nil)
		interation.donate {error in
			if let error = error {
				print("Error donating intent: \(error)")
			}
		}
		//INRelevantShortcut for Siri watchface
	}
}
