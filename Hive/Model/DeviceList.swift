//
//  DeviceList.swift
//  Hive
//
//  Created by James Froggatt on 04.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import Foundation

struct DeviceList {
	var api: APIManaging, sessionID: SessionID, devices: [Device]
	init(api: APIManaging = APIManager(), sessionID: SessionID, devices: [Device]) {
		self.api = api; self.sessionID = sessionID; self.devices = devices
	}
	
	func light(_ device: LightDevice) -> Light {
		return Light(api: api, sessionID: sessionID, device: device)
	}
}
