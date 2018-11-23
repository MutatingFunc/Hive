//
//  APIManager.swift
//  Hive
//
//  Created by James Froggatt on 04.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import Foundation

public struct APIContentType: OptionSet {
	public let rawValue: Int
	public init(rawValue: Int) {self.rawValue = rawValue}
	
	public static let action = APIContentType(rawValue: 0b01)
	public static let product = APIContentType(rawValue: 0b10)
	public static let all: APIContentType = [.action, .product]
}
public protocol APIManaging {
	func login(with credentials: LoginCredentials, contentType: APIContentType, completion: @escaping (Response<LoginInfo>) -> ()) -> Progress
	func quickAction(_ action: ActionDevice, auth: Authorization, completion: @escaping (Response<()>) -> ()) -> Progress
	func setOn(of device: ToggleableDevice, auth: Authorization, completion: @escaping (Response<()>) -> ()) -> Progress
	func updateBrightness(of light: AdjustableBrightnessDevice, auth: Authorization, completion: @escaping (Response<()>) -> ()) -> Progress
	func updateState(of light: ColourLightDevice, auth: Authorization, completion: @escaping (Response<()>) -> ()) -> Progress
}

public struct SessionID: JSONCodable, RawRepresentable, LosslessStringConvertible, Hashable {
	public let rawValue: String
	public init(_ rawValue: String) {self.rawValue = rawValue}
}
public struct LoginInfo {
	let auth: Authorization, devices: [Device], actions: [ActionDevice]
}
public class Authorization {
	let credentials: LoginCredentials
	var sessionID: SessionID
	init(credentials: LoginCredentials, sessionID: SessionID) {
		self.credentials = credentials; self.sessionID = sessionID
	}
}

public let apiManager: APIManaging = debug ? MockAPIManager() : APIManager()

public struct APIManager {
	private let requestHandler: RequestHandling
	public init(requestHandler: RequestHandling = RequestHandler()) {
		self.requestHandler = requestHandler
	}
}

extension APIManager: APIManaging {
	public func login(with credentials: LoginCredentials, contentType: APIContentType, completion: @escaping (Response<LoginInfo>) -> ()) -> Progress {
		let request = APIManager.basicRequest(
			url: URL(string: "https://beekeeper.hivehome.com/1.0/global/login")!,
			method: .post,
			body: LoginRequest(
				username: credentials.username.rawValue,
				password: credentials.password.rawValue,
				products: contentType == .product || contentType == .all,
				actions: contentType == .action || contentType == .all
			),
			sessionID: nil
		)
		return requestHandler.perform(request, ofType: LoginResponse.self) {response in
			completion(response.map(APIManager.loginInfo(credentials)))
		}
	}
	
	func reauthenticateIfNeeded<Result>(_ response: Response<Result>, auth: Authorization, retry: @escaping (Authorization) -> Progress, completion: @escaping (Response<Result>) -> ()) {
		switch response {
		case .success:
			completion(response)
		case .error(let error, _):
			if error as? ErrorResponse == .notAuthorized {
				self.login(with: auth.credentials, contentType: []) {response in
					switch response {
					case .success(let loginInfo, _):
						auth.sessionID = loginInfo.auth.sessionID
						retry(auth)
					case .error:
						completion(response.map{_ in fatalError("Response is error")})
					}
				}
			} else {
				completion(response)
			}
		}
	}
	
	public func quickAction(_ action: ActionDevice, auth: Authorization, completion: @escaping (Response<()>) -> ()) -> Progress {
		let quickActionRequest = APIManager.basicRequest(
			url: APIManager.performActionURL(deviceType: action.typeName, deviceID: action.id),
			method: .post,
			body: QuickActionRequest(),
			sessionID: auth.sessionID
		)
		return requestHandler.perform(quickActionRequest, ofType: QuickActionResponse.self) {response in
			completion(response.map{_ in ()})
		}
	}
	
	public func setOn(of device: ToggleableDevice, auth: Authorization, completion: @escaping (Response<()>) -> ()) -> Progress {
		let setOnRequest = APIManager.basicRequest(
			url: APIManager.updateDeviceURL(deviceType: device.apiTypeName, deviceID: device.id),
			method: .post,
			body: SetOnRequest(status: device.isOn ? .on : .off),
			sessionID: auth.sessionID
		)
		return requestHandler.perform(setOnRequest, ofType: SetOnResponse.self) {response in
			self.reauthenticateIfNeeded(
				response,
				auth: auth,
				retry: {auth in self.setOn(of: device, auth: auth, completion: completion)},
				completion: {response in completion(response.map{_ in ()})}
			)
		}
	}
	
	public func updateBrightness(of light: AdjustableBrightnessDevice, auth: Authorization, completion: @escaping (Response<()>) -> ()) -> Progress {
		let setBrightnessRequest = APIManager.basicRequest(
			url: APIManager.updateDeviceURL(deviceType: light.apiTypeName, deviceID: light.id),
			method: .post,
			body: SetBrightnessRequest(brightness: light.brightness),
			sessionID: auth.sessionID
		)
		return requestHandler.perform(setBrightnessRequest, ofType: SetBrightnessResponse.self) {response in
			self.reauthenticateIfNeeded(
				response,
				auth: auth,
				retry: {auth in self.updateBrightness(of: light, auth: auth, completion: completion)},
				completion: {response in completion(response.map{_ in ()})}
			)
		}
	}
	
	public func updateState(of light: ColourLightDevice, auth: Authorization, completion: @escaping (Response<()>) -> ()) -> Progress {
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
			body: body,
			sessionID: auth.sessionID
		)
		switch light.state {
		case .colour:
			return requestHandler.perform(setStateRequest, ofType: SetHSBResponse.self) {response in
				self.reauthenticateIfNeeded(
					response,
					auth: auth,
					retry: {auth in self.updateState(of: light, auth: auth, completion: completion)},
					completion: {response in completion(response.map{_ in ()})}
				)
			}
		case .white:
			return requestHandler.perform(setStateRequest, ofType: SetLightTemperatureResponse.self) {response in
				self.reauthenticateIfNeeded(
					response,
					auth: auth,
					retry: {auth in self.updateState(of: light, auth: auth, completion: completion)},
					completion: {response in completion(response.map{_ in ()})}
				)
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
	
	static func updateDeviceURL(deviceType: String, deviceID: DeviceID) -> URL {
		return URL(string: "https://beekeeper-uk.hivehome.com/1.0/nodes/\(deviceType)/\(deviceID)")!
	}
	static func performActionURL(deviceType: String, deviceID: DeviceID) -> URL {
		return URL(string: "https://beekeeper-uk.hivehome.com/1.0/actions/\(deviceID)/\(deviceType)")!
	}
	
	static func loginInfo(_ credentials: LoginCredentials) -> (_ response: LoginResponse) throws -> LoginInfo {
		return {response in
			let devices = response.products?.map {product -> Device in
				switch product.type {
				case "warmwhitelight": return LightDevice(
					isGroup: product.isGroup ?? false,
					isOnline: product.props.online,
					name: product.state.name,
					id: DeviceID(product.id),
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
						id: DeviceID(product.id),
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
					id: DeviceID(product.id),
					typeName: product.type
					)
				}
			} ?? []
			let actions = response.actions?.compactMap {action -> ActionDevice? in
				guard let condition = action.events.first, condition.group == .when && condition.type == "quick-action" else {
					return nil
				}
				return ActionDevice(
					isEnabled: action.enabled,
					name: action.name,
					id: DeviceID(action.id),
					typeName: condition.type
				)
			} ?? []
			return LoginInfo(
				auth: Authorization(credentials: credentials, sessionID: SessionID(response.token)),
				devices: devices,
				actions: actions
			)
		}
	}
}
