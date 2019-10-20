//
//  IntentHandler.swift
//  HiveIntents
//
//  Created by James Froggatt on 10.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import Intents

#if canImport(HiveSharedWatch)
import HiveSharedWatch
#else
import HiveShared
#endif

let deviceNotFoundError = "Device not found"

class IntentHandler: INExtension {
	
	override func handler(for intent: INIntent) -> Any {
		// This is the default implementation.  If you want different objects to handle different intents,
		// you can override this and return the handler you want for that particular intent.
		

		return self
	}
}
