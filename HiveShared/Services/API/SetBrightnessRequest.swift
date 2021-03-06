//
//  SetBrightnessRequest.swift
//  Hive
//
//  Created by James Froggatt on 28.09.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import Foundation

struct SetBrightnessRequest: JSONCodable {
	let status = State.Status.on
	let brightness: Float
}

typealias SetBrightnessResponse = SetBrightnessRequest
