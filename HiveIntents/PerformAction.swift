//
//  PerformAction.swift
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

extension IntentHandler: PerformActionIntentHandling {
	func confirm(intent: PerformActionIntent, completion: @escaping (PerformActionIntentResponse) -> Void) {
		completion(.init(code: intent.actionID != nil ? .ready : .failure, userActivity: nil))
	}
	func handle(intent: PerformActionIntent, completion: @escaping (PerformActionIntentResponse) -> Void) {
		tryGetDevices(
			ofType: .action,
			success: {deviceList in
				guard
					let action = deviceList
						.action(id: intent.actionID!)
						.map(deviceList.action)
					else {
						return completion(.failure(actionName: intent.actionName!, error: deviceNotFoundError))
				}
				_ = action.quickAction {response in
					switch response {
					case .success(_, _):
						completion(.success(actionName: intent.actionName!))
					case .error(let error, _):
						completion(.failure(actionName: intent.actionName!, error: error.localizedDescription))
					}
				}
		},
			failure: {error in
				completion(.failure(actionName: intent.actionName!, error: error.localizedDescription))
		}
		)
	}
}
