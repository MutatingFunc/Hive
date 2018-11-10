//
//  DeviceList.swift
//  Hive
//
//  Created by James Froggatt on 04.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import Foundation

public struct DeviceList {
	var api: APIManaging, sessionID: SessionID
	public internal(set) var devices: [Device]
	public init(api: APIManaging = APIManager(), loginInfo: LoginInfo) {
		self.api = api; self.sessionID = loginInfo.sessionID; self.devices = loginInfo.devices
	}
	
	public func device<DeviceType: Device>(named name: String, ofType: DeviceType.Type) -> DeviceType? {
		return self.devices.lazy.compactMap{$0 as? DeviceType}.first{$0.name == name}
	}
	
	public func light(_ device: LightDevice) -> Light {
		return Light(api: api, sessionID: sessionID, device: device)
	}
	public func colourLight(_ device: ColourLightDevice) -> ColourLight {
		return ColourLight(api: api, sessionID: sessionID, device: device)
	}
	public func action(_ device: ActionDevice) -> Action {
		return Action(api: api, sessionID: sessionID, device: device)
	}
}
