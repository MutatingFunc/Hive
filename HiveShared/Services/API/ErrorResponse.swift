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
	public static let notAuthorized = ErrorResponse(error: KnownError.notAuthorized.rawValue)
	public static let malformedRequest = ErrorResponse(error: KnownError.malformedRequest.rawValue)
	public static let notFound = ErrorResponse(error: KnownError.notFound.rawValue)
	
	let error: String
	
	public var errorDescription: String? {
		switch error {
		case KnownError.notAuthorized.rawValue: return "Login session timed out"
		case KnownError.malformedRequest.rawValue: return "Malformed request sent"
		case KnownError.notFound.rawValue: return "Device offline"
		case _: return error
		}
	}
	
	public var localizedDescription: String {
		return errorDescription ?? error
	}
	
	private enum KnownError: String {
		case notAuthorized = "NOT_AUTHORIZED"
		case malformedRequest = "MALFORMED_REQUEST"
		case notFound = "NOT_FOUND"
	}
}
