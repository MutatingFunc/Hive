//
//  SettingsManager.swift
//  Hive
//
//  Created by James Froggatt on 23.09.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import Foundation

public protocol SettingsManaging {
	var currentVersion: String {get}
	var disableAPIWarning: Bool {get nonmutating set}
	var favourites: Set<DeviceID> {get nonmutating set}
}

private let keyVersion = "currentVersion"
private let keyAPIWarningDisabled = "APIWarning"
private let keyFavourites = "favourites"

public struct SettingsManager {
	private let ud: UserDefaults
	public init(userDefaults: UserDefaults = .standard) {
		self.ud = userDefaults
		ud.register(defaults: [
			keyVersion: "0",
			keyAPIWarningDisabled: false
		])
	}
}

extension SettingsManager: SettingsManaging {
	public var currentVersion: String {
		return ud.string(forKey: keyVersion)!
	}
	public var disableAPIWarning: Bool {
		get {return ud.bool(forKey: keyAPIWarningDisabled)}
		nonmutating set {ud.set(newValue, forKey: keyAPIWarningDisabled)}
	}
	public var favourites: Set<DeviceID> {
		get {return ud.data(forKey: keyFavourites).flatMap(Set<DeviceID>.init(data:)) ?? []}
		nonmutating set {
			if newValue.count > 100 {
				let newValue = Set(newValue.prefix(100))
				ud.set(newValue.json(), forKey: keyFavourites)
			} else {
				ud.set(newValue.json(), forKey: keyFavourites)
			}
		}
	}
}

extension Set: JSONCodable where Element: JSONCodable {}
