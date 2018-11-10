//
//  DeviceList.swift
//  Hive
//
//  Created by James Froggatt on 04.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import Foundation

struct DeviceList {
	var api: APIManaging, activityService: ActivityService, sessionID: SessionID, devices: [Device]
	init(api: APIManaging = APIManager(), activityService: ActivityService = ActivityService(), sessionID: SessionID, devices: [Device]) {
		self.api = api; self.activityService = activityService; self.sessionID = sessionID; self.devices = devices
	}
	
	func registerActivities() {
		activityService.registerActivities(devices: self.devices)
	}
	
	func light(_ device: LightDevice) -> Light {
		return Light(api: api, sessionID: sessionID, device: device)
	}
	func colourLight(_ device: ColourLightDevice) -> ColourLight {
		return ColourLight(api: api, sessionID: sessionID, device: device)
	}
	func action(_ device: ActionDevice) -> Action {
		return Action(api: api, sessionID: sessionID, device: device)
	}
}
