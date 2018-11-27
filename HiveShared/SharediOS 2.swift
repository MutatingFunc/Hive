//
//  SharediOS.swift
//  HiveShared
//
//  Created by James Froggatt on 11.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

#if canImport(UIKit)
import UIKit

public extension UIViewController {
	private func showError(title: String, description: String) {
		let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		self.present(alert, animated: true)
	}
	func showError(_ error: Error, domain: String) {
		self.showError(
			title: domain + " Error",
			description: error.localizedDescription
		)
	}
}

public extension UILabel {
	func flashError(_ string: String, completion: @escaping () -> ()) {
		let text = self.text
		self.text = string
		Timer.scheduledTimer(withTimeInterval: 3, repeats: false) {[weak self] _ in
			self?.text = text
			completion()
		}
	}
}
#endif
