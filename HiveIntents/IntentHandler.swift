//
//  IntentHandler.swift
//  HiveIntents
//
//  Created by James Froggatt on 10.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import Intents

import HiveShared

let deviceNotFoundError = "Device not found"

class IntentHandler: INExtension {
	
	override func handler(for intent: INIntent) -> Any {
		// This is the default implementation.  If you want different objects to handle different intents,
		// you can override this and return the handler you want for that particular intent.
		

		return self
	}
	
	func tryGetDevices(login: Login = Login(), ofType contentType: APIContentType, success: @escaping (DeviceList) -> (), failure: @escaping (Error) -> ()) {
		do {
			_ = login.login(credentials: try .savedCredentials(), contentType: contentType) {response in
				switch response {
				case .success(let loginInfo, _):
					success(DeviceList(loginInfo: loginInfo))
				case .error(let error, _):
					failure(error)
				}
			}
		} catch {
			failure(error)
		}
	}
}
