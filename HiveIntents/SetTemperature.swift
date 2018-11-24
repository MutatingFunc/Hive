//
//  SetTemperature.swift
//  HiveIntents
//
//  Created by James Froggatt on 18.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import Foundation

#if canImport(HiveSharedWatch)
import HiveSharedWatch
#else
import HiveShared
#endif

extension IntentHandler: SetTemperatureIntentHandling {
	func confirm(intent: SetTemperatureIntent, completion: @escaping (SetTemperatureIntentResponse) -> Void) {
		let isValid: (Float?) -> Bool = {
			$0.map((0...100).contains) ?? true
		}
		completion(.init(code:
			intent.lightID != nil
				&& intent.temperature != nil
				&& isValid(intent.temperature?.floatValue)
				&& isValid(intent.brightness?.floatValue)
				? .ready
				: .failure, userActivity: nil))
	}
	func handle(intent: SetTemperatureIntent, completion: @escaping (SetTemperatureIntentResponse) -> Void) {
		tryGetDevices(
			ofType: .product,
			success: {deviceList in
				guard
					var light = deviceList
						.device(id: intent.lightID!, ofType: ColourLightDevice.self)
						.map(deviceList.colourLight)
					else {
						return completion(.failure(lightName: intent.lightName!, error: deviceNotFoundError))
				}
				intent.lightName = light.device.name
				_ = light.setState(.white(
					temperature: intent.temperature!.floatValue,
					brightness: intent.brightness?.floatValue ?? light.device.brightness
				), sender: nil) {response in
					if light.device.isOnline == false {
						return completion(.offline(lightName: light.device.name))
					}
					switch response {
					case .success(_, _):
						switch (intent.temperature, intent.brightness) {
						case let (t?, b?):
							completion(.success(lightName: light.device.name, brightness: b, temperature: t))
						case let (t?, nil):
							completion(.successT(lightName: light.device.name, temperature: t))
						case _:
							completion(.failure(lightName: light.device.name, error: "Succeeded with unrecognised parameter combination"))
						}
					case .error(let error, _):
						completion(.failure(lightName: light.device.name, error: error.localizedDescription))
					}
				}
		},
			failure: {error in
				completion(.failure(lightName: intent.lightName!, error: error.localizedDescription))
			}
		)
	}
}
