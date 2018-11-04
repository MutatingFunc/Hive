//
//  Device.swift
//  Hive
//
//  Created by James Froggatt on 04.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import Foundation

protocol Device {
	var isOnline: Bool {get}
	var name: String {get}
	var id: String {get}
	var typeName: String {get}
}
struct UnknownDevice: Device {
	var isOnline: Bool, name: String, id: String, typeName: String
	init(isOnline: Bool, name: String, id: String, typeName: String) {
		self.isOnline = isOnline; self.name = name; self.id = id; self.typeName = typeName
	}
}

struct LightDevice: Device {
	var isOnline: Bool, name: String, id: String, typeName: String
	var isOn: Bool
	/// From 1 to 100
	var brightness: Float
	init(isOnline: Bool, name: String, id: String, typeName: String, isOn: Bool, brightness: Float) {
		self.isOnline = isOnline; self.name = name; self.id = id; self.typeName = typeName; self.isOn = isOn; self.brightness = brightness
	}
}
