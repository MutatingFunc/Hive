//
//  ErrorResponse.swift
//  Hive
//
//  Created by James Froggatt on 13.10.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import Foundation

//status code 400
public struct ErrorResponse: JSONCodable, LocalizedError, Hashable {
	public static let notAuthorized = ErrorResponse(error: KnownErrors.notAuthorized.rawValue)
	public static let malformedRequest = ErrorResponse(error: KnownErrors.malformedRequest.rawValue)
	
	let error: String
	
	public var errorDescription: String? {
		return error
	}
	
	enum KnownErrors: String {
		case notAuthorized = "NOT_AUTHORIZED"
		case malformedRequest = "MALFORMED_REQUEST"
	}
}
