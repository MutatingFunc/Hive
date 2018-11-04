//
//  SetBrightness.swift
//  Hive
//
//  Created by James Froggatt on 28.09.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import Foundation

struct SetBrightnessRequest: JSONCodable {
	let nodes: [Node]
	
	init(isOn: Bool, brightnessWhenOn: Int) {
		self.nodes = [
			Node(attributes: .init(
				state: .init(targetValue: isOn ? "ON" : "OFF"),
				brightness: .init(targetValue: brightnessWhenOn)
			))
		]
	}
	
	struct Node: JSONCodable {
		let attributes: Attributes
		
		struct Attributes: JSONCodable {
			let state: State
			let brightness: Brightness
			
			struct State: JSONCodable {
				let targetValue: String
			}
			struct Brightness: JSONCodable {
				let targetValue: Int
			}
		}
	}
}

typealias SetBrightnessResponse = DeviceListResponse.Node
