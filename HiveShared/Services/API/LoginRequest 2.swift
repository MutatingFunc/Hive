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
	let products: Bool
	let actions: Bool
	let homes = false
}

struct LoginResponse: JSONCodable {
	//let user
	let token: String
	let products: [ProductResponse]?
	let actions: [ActionResponse]?
}

struct ProductResponse: JSONCodable {
	let id: String
	let type: String
	let props: Props
	struct Props: JSONCodable {
		let online: Bool
		let colourTemperature: ColourTemperatureLimits?
		struct ColourTemperatureLimits: JSONCodable {
			let min: Int, max: Int
		}
	}
	let state: State
	let isGroup: Bool? // ?? false
}
struct State: JSONCodable {
	let name: String
	let status: Status?
	enum Status: String, JSONCodable {
		case on = "ON"
		case off = "OFF"
	}
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

struct ActionResponse: JSONCodable {
	let id: String
	let name: String
	let enabled: Bool
	let events: [EventItem]
	struct EventItem: JSONCodable {
		var group: Group
		enum Group: String, JSONCodable {
			case when = "when"
			case then = "then"
		}
		var type: String
		var id: String?
		var duration: Int? //seconds
	}
}
