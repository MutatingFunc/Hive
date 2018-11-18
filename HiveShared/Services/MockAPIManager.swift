//
//  MockAPIManager.swift
//  HiveShared
//
//  Created by James Froggatt on 11.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import Foundation

public struct MockAPIManager: APIManaging {
	public init() {}
	
	public func login(with credentials: LoginCredentials, contentType: APIContentType, completion: @escaping (Response<LoginInfo>) -> ()) -> Progress {
		completion(
			Response.success(
				LoginInfo(
					sessionID: SessionID("mock"),
					devices: Array(repeating: LightDevice(isGroup: false, isOnline: true, name: "Device", id: DeviceID("Light"), typeName: "light type", isOn: true, brightness: 50), count: 20)
						+ [ColourLightDevice(isGroup: false, isOnline: true, name: "Device", id: DeviceID("Colour Light"), typeName: "colour light type", isOn: true, state: .colour(hue: 50, saturation: 50, brightness: 50), minTemp: 0, maxTemp: 100)],
					actions: Array(repeating: ActionDevice(isEnabled: true, name: "Device", id: DeviceID("Action"), typeName: "action type"), count: 20)
				),
				URLResponse()
			)
		)
		return Progress(totalUnitCount: 0)
	}
	
	public func quickAction(_ action: ActionDevice, sessionID: SessionID, completion: @escaping (Response<()>) -> ()) -> Progress {
		completion(Response.success((), URLResponse()))
		return Progress(totalUnitCount: 0)
	}
	
	public func setOn(of device: ToggleableDevice, sessionID: SessionID, completion: @escaping (Response<()>) -> ()) -> Progress {
		completion(Response.success((), URLResponse()))
		return Progress(totalUnitCount: 0)
	}
	
	public func updateBrightness(of light: AdjustableBrightnessDevice, sessionID: SessionID, completion: @escaping (Response<()>) -> ()) -> Progress {
		completion(Response.success((), URLResponse()))
		return Progress(totalUnitCount: 0)
	}
	
	public func updateState(of light: ColourLightDevice, sessionID: SessionID, completion: @escaping (Response<()>) -> ()) -> Progress {
		completion(Response.success((), URLResponse()))
		return Progress(totalUnitCount: 0)
	}
}
