//
//  Devices.swift
//  Hive
//
//  Created by James Froggatt on 04.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import Foundation

public struct DeviceID: JSONCodable, RawRepresentable, LosslessStringConvertible, Hashable {
	public var rawValue: String
	public init(_ rawValue: String) {self.rawValue = rawValue}
}
public protocol Device {
	var isGroup: Bool {get}
	var isOnline: Bool {get}
	var name: String {get}
	var id: DeviceID {get}
	var typeName: String {get}
}
extension Device {
	var apiTypeName: String {
		return isGroup ? "productgroup" : typeName
	}
}
public extension Device {
	func isFavourite(settingsManager: SettingsManaging = SettingsManager()) -> Bool {
		return settingsManager.favourites.contains(self.id)
	}
	func setIsFavourite(_ newValue: Bool, settingsManager: SettingsManaging = SettingsManager()) {
		if newValue {settingsManager.favourites.insert(self.id)}
		else {settingsManager.favourites.remove(self.id)}
	}
	func toggleIsFavourite(settingsManager: SettingsManaging = SettingsManager()) {
		self.setIsFavourite(self.isFavourite(settingsManager: settingsManager) == false)
	}
}

public protocol ToggleableDevice: Device {
	var isOn: Bool {get set}
}
public protocol AdjustableBrightnessDevice: Device {
	var brightness: Float {get set}
}

public typealias AnyLightDevice = ToggleableDevice & AdjustableBrightnessDevice

public struct UnknownDevice: Device {
	public var isGroup: Bool, isOnline: Bool, name: String, id: DeviceID, typeName: String
}

public struct LightDevice: ToggleableDevice, AdjustableBrightnessDevice {
	public var isGroup: Bool, isOnline: Bool, name: String, id: DeviceID, typeName: String
	public var isOn: Bool
	/// From 1 to 100
	public var brightness: Float
}
public struct ColourLightDevice: ToggleableDevice {
	public var isGroup: Bool, isOnline: Bool, name: String, id: DeviceID, typeName: String
	public var isOn: Bool
	public enum State {
		case white(temperature: Float, brightness: Float)
		case colour(hue: Float, saturation: Float, brightness: Float)
	}
	public var state: State
	public var minTemp: Int, maxTemp: Int
}
extension ColourLightDevice: AdjustableBrightnessDevice {
	public var brightness: Float {
		get {
			switch self.state {
			case .white(temperature: _, brightness: let brightness):
				return brightness
			case .colour(hue: _, saturation: _, brightness: let brightness):
				return brightness
			}
		}
		set {
			switch self.state {
			case .white(temperature: let temperature, brightness: _):
				self.state = .white(temperature: temperature, brightness: newValue)
			case .colour(hue: let hue, saturation: let saturation, brightness: _):
				self.state = .colour(hue: hue, saturation: saturation, brightness: newValue)
			}
		}
	}
}

public struct ActionDevice {
	public var isEnabled: Bool, name: String, id: DeviceID, typeName: String
}
extension ActionDevice: Device {
	public var isGroup: Bool {return false}
	public var isOnline: Bool {return isEnabled}
}
