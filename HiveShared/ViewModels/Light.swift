//
//  Light.swift
//  Hive
//
//  Created by James Froggatt on 04.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import Foundation
import Intents

public struct Light {
	var api: APIManaging, sessionID: SessionID
	public internal(set) var device: LightDevice
	public init(api: APIManaging = APIManager(), sessionID: SessionID, device: LightDevice) {
		self.api = api; self.sessionID = sessionID; self.device = device
	}
	
	public mutating func setBrightness(_ brightness: Float, completion: @escaping () -> ()) -> Progress {
		self.device.isOn = brightness > 0
		if brightness > 0 {
			self.device.brightness = brightness
		}
		donateIntent(isOn: brightness != 0)
		if brightness != 0 {
			donateIntent(brightness: brightness)
		}
		return api.updateBrightness(of: self.device, sessionID: self.sessionID, completion: completion)
	}
	
	public mutating func setOn(_ isOn: Bool, completion: @escaping () -> ()) -> Progress {
		self.device.isOn = isOn
		donateIntent(isOn: isOn)
		return api.setOn(of: self.device, sessionID: self.sessionID, completion: completion)
	}
	
	func donateIntent(brightness: Float) {
		let intent = SetBrightnessIntent()
		intent.lightName = device.name
		intent.brightness = NSNumber(value: brightness)
		let interation = INInteraction(intent: intent, response: nil)
		interation.donate {error in
			if let error = error {
				print("Error donating intent: \(error)")
			}
		}
		//INRelevantShortcut for Siri watchface
	}
	
	func donateIntent(isOn: Bool) {
		let intent = ToggleLightIntent()
		intent.lightName = device.name
		intent.state = isOn ? .on : .off
		let interation = INInteraction(intent: intent, response: nil)
		interation.donate {error in
			if let error = error {
				print("Error donating intent: \(error)")
			}
		}
		//INRelevantShortcut for Siri watchface
	}
}
