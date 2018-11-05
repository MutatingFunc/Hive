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
	let actions: [Action]
}

struct Product: JSONCodable {
	let id: String
	let type: String
	let props: Props
	let state: State
	struct Props: JSONCodable {
		let online: Bool
		let colourTemperature: ColourTemperatureLimits?
		struct ColourTemperatureLimits: JSONCodable {
			let min: Int, max: Int
		}
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
	let hue: Int? //1 to 100
	let saturation: Int? //1 to 100
	let mode: Mode?
	enum Mode: String, JSONCodable {
		case manual = "MANUAL"
		case schedule = "SCHEDULE"
	}
	let colourMode: ColourMode?
	enum ColourMode: String, JSONCodable {
		case colour = "COLOUR"
		case white = "WHITE"
	}
	let colourTemperature: Int? //2700 to 6535
}

struct Action: JSONCodable {
	let id: String
	let name: String
	let enabled: Bool
	//let events
}
