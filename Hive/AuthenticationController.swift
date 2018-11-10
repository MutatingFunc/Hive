//
//  AuthenticationController.swift
//  Hive
//
//  Created by James Froggatt on 08.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import UIKit

class AuthenticationController: UIViewController {
	override func viewDidLoad() {
	}
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.presentationController!.containerView!.backgroundColor = .clear
		self.presentationController!.containerView!.superview!.backgroundColor = .clear
	}
}
