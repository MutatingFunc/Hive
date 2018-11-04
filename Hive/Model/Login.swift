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
	
	func login(credentials: LoginCredentials, completion: @escaping (Response<LoginInfo>) -> ()) -> Progress {
		return self.api.login(with: credentials, completion: completion)
	}
}
