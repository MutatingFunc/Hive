//
//  SetColour.swift
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

extension IntentHandler: SetColourIntentHandling {
	func confirm(intent: SetColourIntent, completion: @escaping (SetColourIntentResponse) -> Void) {
		let isValid: (Float?) -> Bool = {
			$0.map((0...100).contains) ?? true
		}
		completion(.init(code:
			intent.lightName != nil
				&& (intent.hue != nil || intent.saturation != nil)
				&& isValid(intent.hue?.floatValue)
				&& isValid(intent.saturation?.floatValue)
				&& isValid(intent.brightness?.floatValue)
				? .ready
				: .failure, userActivity: nil))
	}
	func handle(intent: SetColourIntent, completion: @escaping (SetColourIntentResponse) -> Void) {
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
				let hue: Float?
				let saturation: Float?
				switch light.device.state {
				case let .colour(h, s, _):
					hue = h
					saturation = s
				case .white:
					hue = nil
					saturation = nil
				}
				_ = light.setState(.colour(
					hue: intent.hue?.floatValue ?? hue ?? 100,
					saturation: intent.saturation?.floatValue ?? saturation ?? 100,
					brightness: intent.brightness?.floatValue ?? light.device.brightness
				), sender: nil) {response in
					switch response {
					case .success(_, _):
						switch (intent.hue, intent.saturation, intent.brightness) {
						case let (h?, s?, b?):
							completion(.success(lightName: intent.lightName!, hue: h, saturation: s, brightness: b))
						case let (h?, s?, nil):
							completion(.successHS(lightName: intent.lightName!, hue: h, saturation: s))
						case let (h?, nil, nil):
							completion(.successH(lightName: intent.lightName!, hue: h))
						case let (nil, s?, nil):
							completion(.successS(lightName: intent.lightName!, saturation: s))
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
