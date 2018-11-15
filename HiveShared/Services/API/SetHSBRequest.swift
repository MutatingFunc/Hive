//
//  SetHSBRequest.swift
//  HiveShared
//
//  Created by James Froggatt on 12.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import Foundation

struct SetHSBRequest: JSONCodable {
	let status = State.Status.on, colourMode = State.ColourMode.colour, hue: Int /*0 to 359*/, saturation: Int, value: Int //1 to 100
}

typealias SetHSBResponse = SetHSBRequest

struct SetLightTemperatureRequest: JSONCodable {
	let status = State.Status.on, colourMode = State.ColourMode.white, colourTemperature: Int, brightness: Int
}

typealias SetLightTemperatureResponse = SetLightTemperatureRequest
