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
	public internal(set) var device: ColourLightDevice
	public init(api: APIManaging = APIManager(), sessionID: SessionID, device: ColourLightDevice) {
		self.api = api; self.sessionID = sessionID; self.device = device
	}
	
	public mutating func setState(_ state: ColourLightDevice.State?, completion: @escaping () -> ()) -> Progress {
		if let state = state {
			self.device.state = state
		}
		self.device.isOn = state != nil
		return api.updateState(of: self.device, sessionID: self.sessionID, completion: completion)
	}
}
