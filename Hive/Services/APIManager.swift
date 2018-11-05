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
	func updateState(of light: ColourLightDevice, sessionID: SessionID, completion: @escaping () -> ()) -> Progress
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
			url: APIManager.updateDeviceURL(deviceType: light.apiTypeName, deviceID: light.id),
			method: .post,
			body: light.isOn
				? SetBrightnessRequest(brightness: light.brightness)
				: SetOnRequest(status: .off),
			sessionID: sessionID
		)
		return requestHandler.perform(setBrightnessRequest, ofType: SetBrightnessResponse.self) {response in
			completion()
		}
	}
	
	func updateState(of light: ColourLightDevice, sessionID: SessionID, completion: @escaping () -> ()) -> Progress {
		let body: JSONCodable
		switch light.state {
		case let .colour(hue: h, saturation: s, brightness: b):
			let h = Float(h) * 360 / 100
			body = SetHSBRequest(hue: Int(h), saturation: Int(s), value: Int(b))
		case let .white(temperature: h, brightness: b):
			let h = (h * Float(light.maxTemp - light.minTemp) + Float(light.minTemp)) / 100
			body = SetLightTemperatureRequest(colourTemperature: Int(h), brightness: Int(b))
		}
		let setStateRequest = APIManager.basicRequest(
			url: APIManager.updateDeviceURL(deviceType: light.apiTypeName, deviceID: light.id),
			method: .post,
			body: light.isOn
				? body
				: SetOnRequest(status: .off),
			sessionID: sessionID
		)
		
		switch light.state {
		case .colour:
			return requestHandler.perform(setStateRequest, ofType: SetHSBResponse.self) {response in
				completion()
			}
		case .white:
			return requestHandler.perform(setStateRequest, ofType: SetLightTemperatureResponse.self) {response in
				completion()
			}
		}
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
					isGroup: product.isGroup ?? false,
					isOnline: product.props.online,
					name: product.state.name,
					id: product.id,
					typeName: product.type,
					isOn: product.state.status == .on,
					brightness: product.state.brightness ?? 100
				)
				case "colourtuneablelight":
					let minColourTemp = product.props.colourTemperature?.min ?? 2700
					let maxColourTemp = product.props.colourTemperature?.max ?? 6535
					return ColourLightDevice(
						isGroup: product.isGroup ?? false,
						isOnline: product.props.online,
						name: product.state.name,
						id: product.id,
						typeName: product.type,
						isOn: product.state.status == .on,
						state: product.state.colourMode == .colour
							? ColourLightDevice.State.colour(
									hue: Float(product.state.hue ?? 0) * 100 / 360,
									saturation: Float(product.state.saturation ?? 100),
									brightness: product.state.brightness?.rounded() ?? 100
								)
							: ColourLightDevice.State.white(
									temperature:
										Float((product.state.colourTemperature ?? maxColourTemp) - minColourTemp) * 100
										/ Float(maxColourTemp - minColourTemp),
									brightness: product.state.brightness?.rounded() ?? 100
								),
						minTemp: minColourTemp,
						maxTemp: maxColourTemp
					)
				case _: return UnknownDevice(
					isGroup: product.isGroup ?? false,
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
