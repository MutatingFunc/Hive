//
//  LoginRequest.swift
//  Hive
//
//  Created by James Froggatt on 22.09.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import Foundation

struct LoginRequest: JSONCodable {
	struct Session: JSONCodable {
		let username: String
		let password: String
		let caller = "WEB"
	}
	
	let sessions: [Session]
	init(sessions: [Session]) {
		self.sessions = sessions
	}
	init(username: String, password: String) {
		self.sessions = [.init(username: username, password: password)]
	}
}

struct LoginResponse: JSONCodable {
	let sessions: [Session]
	
	struct Session: JSONCodable {
		let id: String
		let username: String
		let userId: String
		let sessionId: String
		let latestSupportedApiVersion: String
	}
}
