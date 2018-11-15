//
//  SettingsManager.swift
//  Hive
//
//  Created by James Froggatt on 23.09.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import Foundation

public protocol SettingsManaging {
	var favourites: Set<DeviceID> {get nonmutating set}
}

private let keyFavourites = "favourites"

public struct SettingsManager {
	private let local: UserDefaults
	#if os(iOS)
	private let cloud: NSUbiquitousKeyValueStore
	public init(cloud: NSUbiquitousKeyValueStore = .default, local: UserDefaults = UserDefaults(suiteName: "group.James.Hive")!) {
		self.cloud = cloud; self.local = local
	}
	#else
	public init(local: UserDefaults = UserDefaults(suiteName: "group.James.Hive")!) {
		self.local = local
	}
	#endif
}

extension SettingsManager: SettingsManaging {
	static var hasSynced = false
	public func syncFromCloud(force: Bool = false) {
		guard force || SettingsManager.hasSynced == false else {
			return
		}
		#if os(iOS)
		if let favourites = cloud.data(forKey: keyFavourites) {
			local.set(favourites, forKey: keyFavourites)
		}
		#endif
		SettingsManager.hasSynced = true
	}
	public var favourites: Set<DeviceID> {
		get {
			syncFromCloud()
			return local.data(forKey: keyFavourites).flatMap(Set<DeviceID>.init(data:)) ?? []
		}
		nonmutating set {
			syncFromCloud()
			let json: Data
			if newValue.count > 100 {
				json = Set(newValue.prefix(100)).json()
			} else {
				json = newValue.json()
			}
			local.set(json, forKey: keyFavourites)
			#if os(iOS)
			cloud.set(json, forKey: keyFavourites)
			#endif
		}
	}
}

extension Set: JSONCodable where Element: JSONCodable {}
