//
//  Login.swift
//  Hive
//
//  Created by James Froggatt on 04.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import Foundation

struct Login {
	var api: APIManaging
	init(api: APIManaging = APIManager()) {
		self.api = api
	}
	
	func login(credentials: LoginCredentials, completion: @escaping (Response<(sessionID: SessionID, devices: [Device])>) -> ()) -> Progress {
		let progress = Progress(totalUnitCount: 2)
		
		let progress1 = Progress(totalUnitCount: 1)
		progress.addChild(progress1, withPendingUnitCount: 1)
		
		let progress2 = Progress(totalUnitCount: 1)
		progress.addChild(progress2, withPendingUnitCount: 1)
		
		progress1.addChild(self.api.login(with: credentials) {response in
			if case .success(let sessionID, _) = response {
				progress2.addChild(self.api.deviceList(sessionID: sessionID) {response in
					completion(response.map { devices in
						let devices = devices.filter {device in
							device.name.hasPrefix("http://") == false
						}
						return (sessionID, devices)
					})
				}, withPendingUnitCount: 1)
			} else {
				completion(response.map{_ in fatalError("Response is not .success")})
			}
		}, withPendingUnitCount: 1)
		return progress
	}
}
