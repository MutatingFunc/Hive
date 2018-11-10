//
//  AppDelegate.swift
//  Hive
//
//  Created by James Froggatt on 04.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	var navigationController: UINavigationController? {
		return window?.rootViewController as? UINavigationController
	}
	func authenticationController() -> UIViewController? {
		return window?.rootViewController?.storyboard?.instantiateViewController(withIdentifier: "Authentication")
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
	
	func reauthenticate(login: Login = Login()) {
		guard
			let navigationController = self.navigationController,
			let deviceListController = navigationController.topViewController as? DeviceListController,
			let authentication = authenticationController()
		else {
			return
		}
		do {
			let credentials = try LoginCredentials.savedCredentials()
			
			navigationController.present(authentication, animated: true, completion: nil)
			authenticate(login: login, credentials: credentials) {deviceList in
				deviceListController.deviceList = deviceList
				authentication.dismiss(animated: true, completion: nil)
			}
		} catch KeychainError.noPassword {
			returnToLogin(failure: nil)
		} catch {
			returnToLogin(failure: ([error], KeychainError.domain))
		}
	}
	func authenticate(login: Login = Login(), credentials: LoginCredentials, success: @escaping (DeviceList) -> ()) {
		let errorDomain = "Login"
		let progress = login.login(credentials: credentials) {[weak self] response in
			switch response {
			case .success(let response, _):
				success(DeviceList(sessionID: response.sessionID, devices: response.devices))
			case .parsedError(let response, _):
				self?.returnToLogin(failure: (response.errors, errorDomain))
			case .error(let error):
				self?.returnToLogin(failure: ([error], errorDomain))
			}
		}
		_ = progress
	}
	
	func returnToLogin(failure: (errors: [Error], domain: String)? = nil) {
		navigationController?.presentedViewController?.dismiss(animated: failure == nil, completion: nil)
		navigationController?.popToRootViewController(animated: false)
		if let (errors, domain) = failure {
			navigationController?.showErrors(errors, domain: domain)
		}
	}

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		return true
	}
	
	func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
		let activityService = ActivityService()
		guard
			let (deviceID: deviceID, action: action) = activityService.components(for: userActivity),
			let credentials = try? LoginCredentials.savedCredentials()
		else {
			return false
		}
		authenticate(credentials: credentials) { deviceList in
			guard let device = deviceList.devices.first(where: {$0.id == deviceID}) else {
				return
			}
			switch action {
			case .performAction:
				if let device = device as? ActionDevice {
					Action(sessionID: deviceList.sessionID, device: device).quickAction(completion: {})
				}
			case .turnOnLight:
				if let device = device as? LightDevice {
					var light = Light(sessionID: deviceList.sessionID, device: device)
					_ = light.setBrightness(1, completion: {})
				} else if let device = device as? ColourLightDevice {
					var colourLight = ColourLight(sessionID: deviceList.sessionID, device: device)
					//colourLight.setState(ColourLightDevice.State., completion: <#T##() -> ()#>)
				}
			}
		}
		return true
	}
	
	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}


}

