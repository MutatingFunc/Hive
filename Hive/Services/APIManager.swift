//
//  APIManager.swift
//  Hive
//
//  Created by James Froggatt on 04.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import Foundation

protocol APIManaging {
	func login(with credentials: LoginCredentials, completion: @escaping (Response<SessionID>) -> ()) -> Progress
	func deviceList(sessionID: SessionID, completion: @escaping (Response<[Device]>) -> ()) -> Progress
	func updateBrightness(of light: LightDevice, sessionID: SessionID, completion: @escaping (_ success: Bool) -> ()) -> Progress
}

struct SessionID {
	fileprivate let rawValue: String
}

struct APIManager {
	private let requestHandler: RequestHandling
	init(requestHandler: RequestHandling = RequestHandler()) {
		self.requestHandler = requestHandler
	}
}

extension APIManager: APIManaging {
	func login(with credentials: LoginCredentials, completion: @escaping (Response<SessionID>) -> ()) -> Progress {
		let request = APIManager.basicRequest(
			url: URL(string: "https://api.prod.bgchprod.info:443/omnia/auth/sessions")!,
			method: .post,
			body: LoginRequest(username: credentials.username, password: credentials.password),
			sessionID: nil
		)
		return requestHandler.perform(request, ofType: LoginResponse.self) {response in
			completion(response.map(APIManager.sessionID))
		}
	}
	
	func deviceList(sessionID: SessionID, completion: @escaping (Response<[Device]>) -> ()) -> Progress {
		let request = APIManager.basicRequest(
			url: URL(string: "https://api.prod.bgchprod.info:443/omnia/nodes")!,
			method: .get,
			body: nil,
			sessionID: sessionID
		)
		return requestHandler.perform(request, ofType: DeviceListResponse.self) {response in
			completion(response.map(APIManager.deviceList))
		}
	}
	
	func updateBrightness(of light: LightDevice, sessionID: SessionID, completion: @escaping (_ success: Bool) -> ()) -> Progress {
		let request = APIManager.basicRequest(
			url: URL(string: light.href)!,
			method: .put,
			body: SetBrightnessRequest(isOn: light.isOn, brightnessWhenOn: light.brightness),
			sessionID: sessionID
		)
		return requestHandler.perform(request, ofType: SetBrightnessResponse.self, completion: {response in
			if case .success = response {
				completion(true)
			} else {
				completion(false)
			}
		})
	}
}

enum LoginError: Error {
	case noSession
}

private extension APIManager {
	enum APISessionManagingHTTPMethod: String {
		case get = "GET"
		case post = "POST"
		case put = "PUT"
	}
	
	static func basicRequest(url: URL, method: APISessionManagingHTTPMethod, body: JSONCodable?, sessionID: SessionID?) -> URLRequest {
		var request = URLRequest(url: url)
		request.httpMethod = method.rawValue
		request.httpBody = body?.json()
		request.addValue("application/vnd.alertme.zoo-6.1+json", forHTTPHeaderField: "Content-Type")
		request.addValue("application/vnd.alertme.zoo-6.1+json", forHTTPHeaderField: "Accept")
		request.addValue("Hive Web Dashboard", forHTTPHeaderField: "X-Omnia-Client")
		if let sessionID = sessionID?.rawValue {
			request.addValue(sessionID, forHTTPHeaderField: "X-Omnia-Access-Token")
		}
		return request
	}
	
	static func sessionID(_ response: LoginResponse) throws -> SessionID {
		if let sessionID = response.sessions.first?.sessionId {
			return SessionID(rawValue: sessionID)
		} else {
			throw LoginError.noSession
		}
	}
	
	static func deviceList(_ response: DeviceListResponse) -> [Device] {
		return response.nodes.map {node in
			switch node.attributes.nodeType?.reportedValue {
			case .light?: return LightDevice(isOnline: node.attributes.presence.reportedValue == .present, name: node.name, href: node.href, isOn: node.attributes.state?.reportedValue == .on, brightness: node.attributes.brightness?.reportedValue ?? 100)
			case .hub?, .group?, .action?, .schedule?, .colorLight?, _: return UnknownDevice(isOnline: node.attributes.presence.reportedValue == .present, name: node.name, href: node.href, typeName: node.attributes.nodeType?.reportedValue.typeName() ?? "Unknown")
			}
		}
	}
}
