//
//  LoginController.swift
//  Hive
//
//  Created by James Froggatt on 04.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import UIKit

private let domain = "Login"

class LoginController: UIViewController {
	@IBOutlet var usernameField: UITextField!
	@IBOutlet var passwordField: UITextField!
	@IBOutlet var submitButton: UIButton!
	@IBOutlet var loginProgressView: UIProgressView!
	
	let login = Login()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		loginProgressView.isHidden = true
		do {
			let credentials = try LoginCredentials.savedCredentials()
			usernameField.text = credentials.username.rawValue
			passwordField.text = credentials.password.rawValue
		} catch KeychainError.noPassword {
			//ignore
		} catch {
			//ignore
		}
	}

	@IBAction func submitPressed() {
		let credentials = saveCredentials()
		login(credentials: credentials)
	}
	
	func saveCredentials() -> LoginCredentials {
		let credentials = LoginCredentials(username: usernameField.text ?? "", password: passwordField.text ?? "")
		do {
			try credentials.saveToKeychain()
		} catch {
			self.showError(error, domain: KeychainError.domain)
		}
		return credentials
	}
	
	func login(credentials: LoginCredentials) {
		guard submitButton.isEnabled else {
			return
		}
		submitButton.isEnabled = false
		loginProgressView.isHidden = false
		
		let progress = login.login(credentials: credentials) {[weak self] response in
			self?.submitButton.isEnabled = true
			self?.loginProgressView.isHidden = true
			switch response {
			case .success(let response, _):
				self?.performSegue(.login, sender: response)
			case .parsedError(let response, _):
				self?.showErrors(response.errors, domain: domain)
			case .error(let error):
				self?.showError(error, domain: domain)
			}
		}
		loginProgressView.observedProgress = progress
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let target = segue.destination as? DeviceListController, let response = sender as? LoginInfo {
			target.deviceList = DeviceList(sessionID: response.sessionID, devices: response.devices)
		}
	}
}
