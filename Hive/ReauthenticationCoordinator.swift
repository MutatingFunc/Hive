//
//  ReauthenticationCoordinator.swift
//  Hive
//
//  Created by James Froggatt on 10.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import UIKit

import HiveShared

class ReauthenticationCoordinator {
	static var shared: ReauthenticationCoordinator?
	
	let navigationController: RootNav
	init(navigationController: RootNav) {
		self.navigationController = navigationController
		ReauthenticationCoordinator.shared = self
	}
	
	func authenticationController() -> UIViewController? {
		return navigationController.storyboard?.instantiateViewController(withIdentifier: "Authentication")
	}
	
	func reauthenticate(login: Login = Login()) {
		guard
			let deviceListController = navigationController.topViewController as? DeviceListController,
			let authentication = authenticationController()
			else {
				return
		}
		do {
			let credentials = try LoginCredentials.savedCredentials()
			
			navigationController.authenticationController = authentication
			authenticate(login: login, credentials: credentials) {[navigationController] deviceList in
				deviceListController.deviceList = deviceList
				navigationController.authenticationController = nil
				if authentication.presentingViewController != nil {
					authentication.dismiss(animated: true, completion: nil)
				}
			}
		} catch KeychainError.noPassword {
			returnToLogin(failure: nil)
		} catch {
			returnToLogin(failure: (error, KeychainError.domain))
		}
	}
	func authenticate(login: Login = Login(), credentials: LoginCredentials, success: @escaping (DeviceList) -> ()) {
		let errorDomain = "Login"
		let progress = login.login(credentials: credentials) {[weak self] response in
			switch response {
			case .success(let response, _):
				success(DeviceList(loginInfo: response))
			case .error(let error, _):
				self?.returnToLogin(failure: (error, errorDomain))
			}
		}
		_ = progress
	}
	
	func returnToLogin(failure: (error: Error, domain: String)? = nil) {
		navigationController.presentedViewController?.dismiss(animated: failure == nil, completion: nil)
		navigationController.popToRootViewController(animated: false)
		if let (error, domain) = failure {
			navigationController.showError(error, domain: domain)
		}
	}
}
