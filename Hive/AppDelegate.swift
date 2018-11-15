//
//  AppDelegate.swift
//  Hive
//
//  Created by James Froggatt on 04.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import UIKit

import HiveShared

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	var reauthenticationCoordinator: ReauthenticationCoordinator?
	
	var navigationController: RootNav? {
		return window?.rootViewController as? RootNav
	}
	var loginController: LoginController? {
		return navigationController?.viewControllers.first as? LoginController
	}

	func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
		return true
	}
	func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
		return true
	}
	
	func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
		return true
	}

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		self.reauthenticationCoordinator =
			.shared ?? .init(navigationController: self.navigationController!)
		reauthenticationCoordinator?.reauthenticate()
		return true
	}
	
	func applicationWillResignActive(_ application: UIApplication) {
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		SettingsManager().syncFromCloud(force: true)
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
	}

	func applicationWillTerminate(_ application: UIApplication) {
	}


}

