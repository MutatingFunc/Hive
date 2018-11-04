//
//  LoginRequest.swift
//  Hive
//
//  Created by James Froggatt on 22.09.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import Foundation

struct LoginRequest: JSONCodable {
	let username: String
	let password: String
	let devices = false
	let products = true
	let actions = true
	let homes = false
}

struct LoginResponse: JSONCodable {
	//let user
	let token: String
	let products: [Product]
	//let actions: [Action]
}

struct Product: JSONCodable {
	let id: String
	let type: String
	let props: Props
	let state: State
	struct Props: JSONCodable {
		let online: Bool
	}
}
struct State: JSONCodable {
	let name: String
	let status: Status
	enum Status: String, JSONCodable {
		case on = "ON"
		case off = "OFF"
	}
	let isGroup: Bool? // ?? false
	let brightness: Float?
	let hue: Int? //1 to 100?
	let saturation: Int? //1 to 100?
	let mode: String?
	let colourMode: String?
	let colourTemperature: Int? //includes 4695
}

struct Action: JSONCodable {
	let id: String
	let name: String
	let enabled: Bool
	//let events
}
