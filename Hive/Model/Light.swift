//
//  Light.swift
//  Hive
//
//  Created by James Froggatt on 04.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import Foundation

struct Light {
	var api: APIManaging, sessionID: SessionID, device: LightDevice
	init(api: APIManaging = APIManager(), sessionID: SessionID, device: LightDevice) {
		self.api = api; self.sessionID = sessionID; self.device = device
	}
	
	mutating func setBrightness(_ brightness: Int, completion: @escaping (_ success: Bool) -> ()) -> Progress {
		self.device.isOn = brightness > 0
		if brightness > 0 {
			self.device.brightness = brightness
		}
		return api.updateBrightness(of: self.device, sessionID: self.sessionID, completion: completion)
	}
}
