//
//  RootNav.swift
//  Hive
//
//  Created by James Froggatt on 08.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import UIKit

class RootNav: UINavigationController {
	var authenticationController: UIViewController?
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if let authenticationController = self.authenticationController {
			self.authenticationController = nil
			self.present(authenticationController, animated: true, completion: nil)
		}
	}
}
