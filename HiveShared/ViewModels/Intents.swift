//
//  Intents.swift
//  HiveShared
//
//  Created by James Froggatt on 18.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import Intents

func donateActionIntent(_ device: ActionDevice) {
	let intent = PerformActionIntent()
	intent.actionID = device.id.rawValue
	intent.actionName = device.name
	let interation = INInteraction(intent: intent, response: nil)
	interation.donate {error in
		if let error = error {
			print("Error donating intent: \(error)")
		}
	}
	//INRelevantShortcut for Siri watchface
}

func donateIsOnIntent(_ device: ToggleableDevice) {
	let intent = ToggleLightIntent()
	intent.lightID = device.id.rawValue
	intent.lightName = device.name
	intent.state = device.isOn ? .on : .off
	let interation = INInteraction(intent: intent, response: nil)
	interation.donate {error in
		if let error = error {
			print("Error donating intent: \(error)")
		}
	}
	//INRelevantShortcut for Siri watchface
}

func donateBrightnessIntent(_ device: AdjustableBrightnessDevice) {
	let intent = SetBrightnessIntent()
	intent.lightID = device.id.rawValue
	intent.lightName = device.name
	intent.brightness = NSNumber(value: device.brightness)
	let interation = INInteraction(intent: intent, response: nil)
	interation.donate {error in
		if let error = error {
			print("Error donating intent: \(error)")
		}
	}
	
	//INRelevantShortcut for Siri watchface
}
func donateGetBrightnessIntent(_ device: AdjustableBrightnessDevice) {
	let intent = GetBrightnessIntent()
	intent.lightID = device.id.rawValue
	intent.lightName = device.name
	let interation = INInteraction(intent: intent, response: nil)
	interation.donate {error in
		if let error = error {
			print("Error donating intent: \(error)")
		}
	}
}

func donateColourIntent(_ device: ColourLightDevice, values: Set<ColourLight.SetStateIntentType>) {
	guard case .colour(hue: let hue, saturation: let saturation, brightness: let brightness) = device.state else {
		return
	}
	let intent = SetColourIntent()
	intent.lightID = device.id.rawValue
	intent.lightName = device.name
	if values.contains(.hue) {
		intent.hue = NSNumber(value: hue)
	}
	if values.contains(.saturation) {
		intent.saturation = NSNumber(value: saturation)
	}
	if values.contains(.brightness) {
		intent.brightness = NSNumber(value: brightness)
	}
	let interation = INInteraction(intent: intent, response: nil)
	interation.donate {error in
		if let error = error {
			print("Error donating intent: \(error)")
		}
	}
	//INRelevantShortcut for Siri watchface
}

func donateTemperatureIntent(_ device: ColourLightDevice, values: Set<ColourLight.SetStateIntentType>) {
	guard case .white(temperature: let temperature, brightness: let brightness) = device.state else {
		return
	}
	let intent = SetTemperatureIntent()
	intent.lightID = device.id.rawValue
	intent.lightName = device.name
	if values.contains(.temperature) {
		intent.temperature = NSNumber(value: temperature)
	}
	if values.contains(.brightness) {
		intent.brightness = NSNumber(value: brightness)
	}
	let interation = INInteraction(intent: intent, response: nil)
	interation.donate {error in
		if let error = error {
			print("Error donating intent: \(error)")
		}
	}
	//INRelevantShortcut for Siri watchface
}
