//
//  ErrorResponse.swift
//  Hive
//
//  Created by James Froggatt on 13.10.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import Foundation

//status code 400
struct ErrorResponse: JSONCodable, LocalizedError {
	let errors: [Error]
	
	var errorDescription: String? {
		return errors.first?.localizedDescription ?? "Unknown error"
	}
	
	struct Error: JSONCodable, LocalizedError {
		let code: String
		let title: String
		
		var errorDescription: String? {
			return title
		}
	}
}
