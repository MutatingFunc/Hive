//
//  GetBrightness.swift
//  HiveIntents
//
//  Created by James Froggatt on 25.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import Foundation

#if canImport(HiveSharedWatch)
import HiveSharedWatch
#else
import HiveShared
#endif

extension IntentHandler: GetBrightnessIntentHandling {
	func confirm(intent: GetBrightnessIntent, completion: @escaping (GetBrightnessIntentResponse) -> Void) {
		completion(.init(code: intent.lightID != nil ? .ready : .failure, userActivity: nil))
	}
	func handle(intent: GetBrightnessIntent, completion: @escaping (GetBrightnessIntentResponse) -> Void) {
		DeviceFetcher().getDevices(
			ofType: .product,
			success: {deviceList in
				guard
					let light = deviceList
						.device(id: intent.lightID!, ofType: LightDevice.self)
						.map(deviceList.light)
					else {
						return completion(.failure(lightName: intent.lightName!, error: deviceNotFoundError))
				}
				
				if light.device.isOnline {
					completion(.success(lightName: light.device.name, brightness: NSNumber(value: Int(light.device.brightness.rounded()))))
				} else {
					return completion(.offline(lightName: light.device.name))
				}
		},
			failure: {error in
				completion(.failure(lightName: intent.lightName!, error: error.localizedDescription))
		}
		)
	}
}
