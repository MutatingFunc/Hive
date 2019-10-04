//
//  RequestHandler.swift
//  Hive
//
//  Created by James Froggatt on 22.09.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import Alamofire

public enum RequestError: String, LocalizedError {
	case loadFailed = "Load failed"
	case unknown = "Unknown"
	
	public var errorDescription: String? {
		return self.rawValue
	}
}

public enum Response<Parsed> {
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

public protocol RequestHandling {
	func perform<Parsed: JSONCodable>(_ request: URLRequest, ofType type: Parsed.Type, completion: @escaping (Response<Parsed>) -> ()) -> Progress
}

public struct RequestHandler {
	private let sessionManager: Alamofire.SessionManager
	public init(sessionManager: Alamofire.SessionManager = .default) {
		self.sessionManager = sessionManager
	}
}

extension RequestHandler: RequestHandling {
	public func perform<Parsed: JSONCodable>(_ request: URLRequest, ofType type: Parsed.Type, completion: @escaping (Response<Parsed>) -> ()) -> Progress {
		let task = sessionManager.request(request).responseData {result in
			if let data = result.data, let response = result.response {
				print("Response: \(response)\n  With data: \(String(data: data, encoding: .ascii) ?? data.description)")
				DispatchQueue.global(qos: .userInitiated).async {
					do {
						let parsed = try Parsed(data: data)
						DispatchQueue.main.async {
							completion(.success(parsed, response))
						}
					} catch(let originalError) {
						do {
							let errorResponse: Error = try ErrorResponse(data: data)
							DispatchQueue.main.async {
								completion(.error(errorResponse, response))
							}
						} catch {
							DispatchQueue.main.async {
								completion(.error(originalError, response))
							}
						}
					}
				}
			} else {
				print("Response error: \(result.error?.localizedDescription ?? "Unknown error")")
				if (result.error as NSError?)?.code == -999 {
					completion(.error(RequestError.loadFailed, result.response))
				} else {
					return completion(.error(result.error ?? RequestError.unknown, result.response))
				}
			}
		}
		print("Request made: \(task)\n  With body: \((task.request?.httpBody).flatMap{String(data: $0, encoding: .utf8)} ?? "")")
		return task.progress
	}
}
