//
//  Device.swift
//  Hive
//
//  Created by James Froggatt on 04.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import Foundation

protocol Device {
	var isGroup: Bool {get}
	var isOnline: Bool {get}
	var name: String {get}
	var id: String {get}
	var typeName: String {get}
}
extension Device {
	var apiTypeName: String {
		return isGroup ? "productgroup" : typeName
	}
}

struct UnknownDevice: Device {
	var isGroup: Bool, isOnline: Bool, name: String, id: String, typeName: String
}

struct LightDevice: Device {
	var isGroup: Bool, isOnline: Bool, name: String, id: String, typeName: String
	var isOn: Bool
	/// From 1 to 100
	var brightness: Float
}
struct ColourLightDevice: Device {
	var isGroup: Bool, isOnline: Bool, name: String, id: String, typeName: String
	var isOn: Bool
	enum State {
		case white(temperature: Float, brightness: Float)
		case colour(hue: Float, saturation: Float, brightness: Float)
	}
	var state: State
	var minTemp: Int, maxTemp: Int
}
