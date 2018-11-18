//
//  ToggleLight.swift
//  HiveIntents
//
//  Created by James Froggatt on 11.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import Foundation

#if canImport(HiveSharedWatch)
import HiveSharedWatch
#else
import HiveShared
#endif

extension IntentHandler: ToggleLightIntentHandling {
	func confirm(intent: ToggleLightIntent, completion: @escaping (ToggleLightIntentResponse) -> Void) {
		completion(.init(code: intent.lightID != nil && intent.state != .unknown ? .ready : .failure, userActivity: nil))
	}
	func handle(intent: ToggleLightIntent, completion: @escaping (ToggleLightIntentResponse) -> Void) {
		tryGetDevices(
			ofType: .product,
			success: {deviceList in
				guard
					var light = deviceList
						.device(id: intent.lightID!, ofType: LightDevice.self)
						.map(deviceList.light)
					else {
						return completion(.failure(lightName: intent.lightName!, state: intent.state, error: deviceNotFoundError))
				}
				_ = light.setIsOn(intent.state == .on) {response in
					switch response {
					case .success(_, _):
						completion(.success(state: intent.state, lightName: intent.lightName!))
					case .error(let error, _):
						completion(.failure(lightName: intent.lightName!, state: intent.state, error: error.localizedDescription))
					}
				}
		},
			failure: {error in
				completion(.failure(lightName: intent.lightName!, state: intent.state, error: error.localizedDescription))
		}
		)
	}
}
