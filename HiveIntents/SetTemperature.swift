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
			intent.lightName != nil
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
						.device(named: intent.lightName!, ofType: ColourLightDevice.self)
						.map(deviceList.colourLight)
					else {
						return completion(.failure(lightName: intent.lightName!, error: deviceNotFoundError))
				}
				_ = light.setState(.white(
					temperature: intent.temperature!.floatValue,
					brightness: intent.brightness?.floatValue ?? light.device.brightness
				), sender: nil) {response in
					switch response {
					case .success(_, _):
						switch (intent.temperature, intent.brightness) {
						case let (t?, b?):
							completion(.success(lightName: intent.lightName!, brightness: b, temperature: t))
						case let (t?, nil):
							completion(.successT(lightName: intent.lightName!, temperature: t))
						case _:
							completion(.failure(lightName: intent.lightName!, error: "Succeeded with unrecognised parameter combination"))
						}
					case .error(let error, _):
						completion(.failure(lightName: intent.lightName!, error: error.localizedDescription))
					}
				}
		},
			failure: {error in
				completion(.failure(lightName: intent.lightName!, error: error.localizedDescription))
		}
		)
	}
}
