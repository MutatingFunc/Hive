//
//  Segues.swift
//  Hive
//
//  Created by James Froggatt on 04.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import UIKit

enum Segue: String {
	case login
}

extension UIViewController {
	func performSegue(_ segue: Segue, sender: Any?) {
		self.performSegue(withIdentifier: segue.rawValue, sender: sender)
	}
}
