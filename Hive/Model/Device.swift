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
	var href: String {get}
	var typeName: String {get}
}
struct UnknownDevice: Device {
	var isOnline: Bool, name: String, href: String, typeName: String
	init(isOnline: Bool, name: String, href: String, typeName: String) {
		self.isOnline = isOnline; self.name = name; self.href = href; self.typeName = typeName
	}
}

struct LightDevice: Device {
	let typeName = "Light"
	var isOnline: Bool, name: String, href: String
	var isOn: Bool
	/// Integer from 1 to 100
	var brightness: Int
	init(isOnline: Bool, name: String, href: String, isOn: Bool, brightness: Int) {
		self.isOnline = isOnline; self.name = name; self.href = href; self.isOn = isOn; self.brightness = brightness
	}
}
