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
	public internal(set) var devices: [Device], actions: [ActionDevice]
	public init(api: APIManaging = apiManager, loginInfo: LoginInfo) {
		self.api = api; self.sessionID = loginInfo.sessionID
		self.devices = loginInfo.devices
		self.actions = loginInfo.actions
		self.sortActions()
		self.sortDevices()
	}
	
	public mutating func sortDevices() {
		self.devices.sort {
			if $0.isFavourite() != $1.isFavourite() {
				return $0.isFavourite() == true
			}
			return $0.name.lexicographicallyPrecedes($1.name)
		}
	}
	public mutating func sortActions() {
		self.actions.sort {
			if $0.isFavourite() != $1.isFavourite() {
				return $0.isFavourite() == true
			}
			return $0.name.lexicographicallyPrecedes($1.name)
		}
	}
	
	public func device<DeviceType: Device>(id: String, ofType: DeviceType.Type) -> DeviceType? {
		return self.devices.lazy.compactMap{$0 as? DeviceType}.first{$0.id.rawValue == id}
	}
	public func action(id: String) -> ActionDevice? {
		return self.actions.first{$0.id.rawValue == id}
	}
	
	public func action(_ device: ActionDevice) -> Action {
		return Action(api: api, sessionID: sessionID, device: device)
	}
	public func toggle(_ device: ToggleableDevice) -> Toggle {
		return Toggle(api: api, sessionID: sessionID, device: device)
	}
	public func light(_ device: LightDevice) -> Light {
		return Light(api: api, sessionID: sessionID, device: device)
	}
	public func colourLight(_ device: ColourLightDevice) -> ColourLight {
		return ColourLight(api: api, sessionID: sessionID, device: device)
	}
}
