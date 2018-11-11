//
//  Login.swift
//  Hive
//
//  Created by James Froggatt on 04.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import Foundation

public struct Login {
	var api: APIManaging
	public init(api: APIManaging = apiManager) {
		self.api = api
	}
	
	public func login(credentials: LoginCredentials, contentType: APIContentType = .all, completion: @escaping (Response<LoginInfo>) -> ()) -> Progress {
		return self.api.login(with: credentials, contentType: contentType, completion: completion)
	}
}
