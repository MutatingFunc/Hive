//
//  SetBrightness.swift
//  HiveIntents
//
//  Created by James Froggatt on 11.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import Foundation

import HiveShared

extension IntentHandler: SetBrightnessIntentHandling {
	func confirm(intent: SetBrightnessIntent, completion: @escaping (SetBrightnessIntentResponse) -> Void) {
		let isValid: (Float?) -> Bool = {
			$0.map((0...100).contains) ?? true
		}
		completion(.init(code: intent.lightName == nil || isValid(intent.brightness?.floatValue) == false ? .failure : .ready, userActivity: nil))
	}
	func handle(intent: SetBrightnessIntent, completion: @escaping (SetBrightnessIntentResponse) -> Void) {
		tryGetDevices(
			ofType: .product,
			success: {deviceList in
				guard
					var light = deviceList
						.device(named: intent.lightName!, ofType: LightDevice.self)
						.map(deviceList.light)
					else {
						return completion(.failure(lightName: intent.lightName!, error: deviceNotFoundError))
				}
				let brightness = intent.brightness?.floatValue ?? 0
				_ = light.setBrightness(brightness) {
					completion(.success(lightName: intent.lightName!, brightness: intent.brightness!))
				}
		},
			failure: {error in
				completion(.failure(lightName: intent.lightName!, error: error.localizedDescription))
		}
		)
	}
}
