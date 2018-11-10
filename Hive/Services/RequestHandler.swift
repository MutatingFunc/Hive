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
	case error(Error, URLResponse?)
	
	func map<Result>(_ transform: (Parsed) throws -> Result) -> Response<Result> {
		switch self {
		case let .success(parsed, urlResponse):
			do {
				return .success(try transform(parsed), urlResponse)
			} catch {
				return .error(error, urlResponse)
			}
		case let .error(error, urlResponse): return .error(error, urlResponse)
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
					} else {
						let error: Error = result.data.flatMap(ErrorResponse.init(data:))
							?? RequestError.parseFailed
						DispatchQueue.main.async {
							completion(.error(error, response))
						}
					}
				}
			} else {
				print("Response error: \(result.error?.localizedDescription ?? "Unknown error")")
				if (result.error as NSError?)?.code == -999 {
					completion(.error(RequestError.loadFailed, nil))
				} else {
					return completion(.error(result.error ?? RequestError.unknown, nil))
				}
			}
		}
		print("Request made: \(task)\n  With body: \((task.request?.httpBody).flatMap{String(data: $0, encoding: .utf8)} ?? "")")
		return task.progress
	}
}
