//
//  SettingsManager.swift
//  Hive
//
//  Created by James Froggatt on 23.09.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import Foundation

protocol SettingsManaging {
	var currentVersion: String {get}
	var disableAPIWarning: Bool {get nonmutating set}
}

private let keyVersion = "currentVersion"
private let keyAPIWarningDisabled = "APIWarning"

struct SettingsManager {
	private let ud: UserDefaults
	init(userDefaults: UserDefaults = .standard) {
		self.ud = userDefaults
		ud.register(defaults: [
			keyVersion: "0",
			keyAPIWarningDisabled: false
		])
	}
}

extension SettingsManager: SettingsManaging {
	var currentVersion: String {
		return ud.string(forKey: keyVersion)!
	}
	var disableAPIWarning: Bool {
		get {return ud.bool(forKey: keyAPIWarningDisabled)}
		nonmutating set {ud.set(newValue, forKey: keyAPIWarningDisabled)}
	}
}
