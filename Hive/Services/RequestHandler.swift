//
//  RequestHandler.swift
//  Hive
//
//  Created by James Froggatt on 22.09.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import Alamofire

enum RequestError: String, LocalizedError {
	case loadFailed = "Load failed"
	case parseFailed = "Failed to parse response"
	case unknown = "Unknown"
	
	var errorDescription: String? {
		return self.rawValue
	}
}

enum Response<Parsed> {
	case success(Parsed, URLResponse)
	case parsedError(ErrorResponse, URLResponse)
	case error(Error)
	
	func map<Result>(_ transform: (Parsed) throws -> Result) -> Response<Result> {
		switch self {
		case let .success(parsed, urlResponse):
			do {
				return .success(try transform(parsed), urlResponse)
			} catch {
				return .error(error)
			}
		case let .parsedError(errorResponse, urlResponse): return .parsedError(errorResponse, urlResponse)
		case let .error(error): return .error(error)
		}
	}
}

protocol RequestHandling {
	func perform<Parsed: JSONCodable>(_ request: URLRequest, ofType type: Parsed.Type, completion: @escaping (Response<Parsed>) -> ()) -> Progress
}

struct RequestHandler {
	private let sessionManager: Alamofire.SessionManager
	init(sessionManager: Alamofire.SessionManager = .default) {
		self.sessionManager = sessionManager
	}
}

extension RequestHandler: RequestHandling {
	func perform<Parsed: JSONCodable>(_ request: URLRequest, ofType type: Parsed.Type, completion: @escaping (Response<Parsed>) -> ()) -> Progress {
		let task = sessionManager.request(request).responseData {result in
			if let data = result.data, let response = result.response {
				print("Response: \(response)\n  With data: \(String(data: data, encoding: .ascii) ?? data.description)")
				DispatchQueue.global(qos: .userInitiated).async {
					if let parsed = Parsed(data: data) {
						DispatchQueue.main.async {
							completion(.success(parsed, response))
						}
					} else if let error = ErrorResponse(data: data) {
						DispatchQueue.main.async {
							completion(.parsedError(error, response))
						}
					} else {
						DispatchQueue.main.async {
							return completion(.error(RequestError.parseFailed))
						}
					}
				}
			} else {
				print("Response error: \(result.error?.localizedDescription ?? "Unknown error")")
				guard let error = result.error else {
					return completion(.error(RequestError.unknown))
				}
				switch (error as NSError).code {
				case -999:
					completion(.error(RequestError.loadFailed))
				case _:
					completion(.error(error))
				}
			}
		}
		print("Request made: \(task)\n  With body: \((task.request?.httpBody).flatMap{String(data: $0, encoding: .utf8)} ?? "")")
		return task.progress
	}
}
