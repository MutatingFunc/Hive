//
//  PerformAction.swift
//  HiveIntents
//
//  Created by James Froggatt on 11.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import Foundation

import HiveShared

extension IntentHandler: PerformActionIntentHandling {
	func confirm(intent: PerformActionIntent, completion: @escaping (PerformActionIntentResponse) -> Void) {
		completion(.init(code: intent.actionName == nil ? .failure : .ready, userActivity: nil))
	}
	func handle(intent: PerformActionIntent, completion: @escaping (PerformActionIntentResponse) -> Void) {
		tryGetDevices(
			ofType: .action,
			success: {deviceList in
				guard
					let action = deviceList
						.device(named: intent.actionName!, ofType: ActionDevice.self)
						.map(deviceList.action)
					else {
						return completion(.failure(actionName: intent.actionName!, error: deviceNotFoundError))
				}
				_ = action.quickAction {
					completion(.success(actionName: intent.actionName!))
				}
		},
			failure: {error in
				completion(.failure(actionName: intent.actionName!, error: error.localizedDescription))
		}
		)
	}
}
