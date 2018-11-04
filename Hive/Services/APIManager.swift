//
//  APIManager.swift
//  Hive
//
//  Created by James Froggatt on 04.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import Foundation

protocol APIManaging {
	func login(with credentials: LoginCredentials, completion: @escaping (Response<LoginInfo>) -> ()) -> Progress
	func updateBrightness(of light: LightDevice, sessionID: SessionID, completion: @escaping () -> ()) -> Progress
}

struct SessionID {
	fileprivate let rawValue: String
}
struct LoginInfo {
	let sessionID: SessionID
	let devices: [Device]
}

struct APIManager {
	private let requestHandler: RequestHandling
	init(requestHandler: RequestHandling = RequestHandler()) {
		self.requestHandler = requestHandler
	}
}

extension APIManager: APIManaging {
	func login(with credentials: LoginCredentials, completion: @escaping (Response<LoginInfo>) -> ()) -> Progress {
		let request = APIManager.basicRequest(
			url: URL(string: "https://beekeeper.hivehome.com/1.0/global/login")!,
			method: .post,
			body: LoginRequest(username: credentials.username, password: credentials.password),
			sessionID: nil
		)
		return requestHandler.perform(request, ofType: LoginResponse.self) {response in
			completion(response.map(APIManager.loginInfo))
		}
	}
	
	func updateBrightness(of light: LightDevice, sessionID: SessionID, completion: @escaping () -> ()) -> Progress {
		let setBrightnessRequest = APIManager.basicRequest(
			url: APIManager.updateDeviceURL(deviceType: light.typeName, deviceID: light.id),
			method: .post,
			body: light.isOn
				? SetBrightnessRequest(brightness: light.brightness)
				: SetOnRequest(status: light.isOn ? .on : .off),
			sessionID: sessionID
		)
		let setOnRequest = APIManager.basicRequest(
			url: APIManager.updateDeviceURL(deviceType: light.typeName, deviceID: light.id),
			method: .post,
			body: SetOnRequest(status: light.isOn ? .on : .off),
			sessionID: sessionID
		)
		let progress = Progress(totalUnitCount: 2)
		let progress2 = Progress(totalUnitCount: 1)
		let progress1 = requestHandler.perform(setBrightnessRequest, ofType: SetBrightnessResponse.self) {[requestHandler] response in
			progress2.addChild(requestHandler.perform(setOnRequest, ofType: SetOnResponse.self) {response in
				completion()
			}, withPendingUnitCount: 1)
		}
		progress.addChild(progress1, withPendingUnitCount: 1)
		progress.addChild(progress2, withPendingUnitCount: 1)
		return progress
	}
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
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		if let sessionID = sessionID?.rawValue {
			request.addValue(sessionID, forHTTPHeaderField: "Authorization")
		}
		return request
	}
	
	static func updateDeviceURL(deviceType: String, deviceID: String) -> URL {
		return URL(string: "https://beekeeper-uk.hivehome.com/1.0/nodes/\(deviceType)/\(deviceID)")!
	}
	
	static func loginInfo(_ response: LoginResponse) throws -> LoginInfo {
		return LoginInfo(
			sessionID: SessionID(rawValue: response.token),
			devices: response.products.map {product in
				switch product.type {
				case "warmwhitelight": return LightDevice(
					isOnline: product.props.online,
					name: product.state.name,
					id: product.id,
					typeName: product.type,
					isOn: product.state.status == .on,
					brightness: product.state.brightness ?? 100
				)
				case _: return UnknownDevice(
					isOnline: product.props.online,
					name: product.state.name,
					id: product.id,
					typeName: product.type
					)
				}
			}
		)
	}
}
