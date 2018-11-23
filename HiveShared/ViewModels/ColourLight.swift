//
//  ColourLight.swift
//  Hive
//
//  Created by James Froggatt on 05.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import Foundation

public struct ColourLight: ViewModel {
	var api: APIManaging, auth: Authorization
	public internal(set) var settingsManager: SettingsManaging, device: ColourLightDevice
	public init(api: APIManaging = apiManager, settingsManager: SettingsManaging = SettingsManager(), auth: Authorization, device: ColourLightDevice) {
		self.api = api; self.settingsManager = settingsManager; self.auth = auth; self.device = device
	}
	
	public mutating func setIsOn(_ isOn: Bool, completion: @escaping (Response<()>) -> ()) -> Progress {
		return vmSetIsOn(isOn, viewModel: &self, completion: completion)
	}
	
	public mutating func setBrightness(_ brightness: Float, completion: @escaping (Response<()>) -> ()) -> Progress {
		return vmSetBrightness(brightness, viewModel: &self, completion: completion)
	}
	
	public enum SetStateSender {
		case hue, saturation, temperature, brightness
	}
	
	public mutating func setState(_ state: ColourLightDevice.State?, sender: SetStateSender?, completion: @escaping (Response<()>) -> ()) -> Progress {
		if let state = state {
			self.device.state = state
		}
		self.device.isOn = state != nil
		donateIsOnIntent(self.device)
		if sender == .hue {
			donateColourIntent(self.device, values: [.hue])
			donateColourIntent(self.device, values: [.hue, .saturation])
		}
		if sender == .saturation {
			donateColourIntent(self.device, values: [.saturation])
			donateColourIntent(self.device, values: [.hue, .saturation])
		}
		if sender == .brightness {
			donateBrightnessIntent(self.device)
		}
		if sender == .temperature {
			donateTemperatureIntent(self.device, values: [.temperature])
		}
		if sender != nil, case .colour = device.state {
			donateColourIntent(self.device, values: [.hue, .saturation, .brightness])
		}
		if sender != nil, case .white = device.state {
			donateTemperatureIntent(self.device, values: [.temperature, .brightness])
		}
		return api.updateState(of: self.device, auth: self.auth, completion: completion)
	}
}
