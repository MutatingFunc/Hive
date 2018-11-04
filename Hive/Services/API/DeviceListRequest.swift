//
//  DeviceListRequest.swift
//  Hive
//
//  Created by James Froggatt on 22.09.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import Foundation

struct DeviceListResponse: JSONCodable {
	let nodes: [Node]
	
	struct Node: JSONCodable, Hashable {
		
		let href: String
		let name: String
		let attributes: Attributes
		
		static func == (lhs: DeviceListResponse.Node, rhs: DeviceListResponse.Node) -> Bool {
			return lhs.href == rhs.href
		}
		func hash(into hasher: inout Hasher) {
			hasher.combine(href)
		}
		
		struct Attributes: JSONCodable {
			let nodeType: NodeType? //absent for http://alertme.com/schema/json/node.class.synthetic.motion.duration.json#
			let presence: Presence
			let lastSeen: LastSeen?
			let state: State?
			let brightness: Brightness?
			
			struct NodeType: JSONCodable {
				let reportedValue: Value
				
				enum Value: String, JSONCodable {
					case hub = "http://alertme.com/schema/json/node.class.hub.json#"
					case light = "http://alertme.com/schema/json/node.class.light.json#"
					case colorLight = "http://alertme.com/schema/json/node.class.colour.tunable.light.json#"
					case action = "http://alertme.com/schema/json/node.class.synthetic.rule.json#"
					case group = "http://alertme.com/schema/json/node.class.synthetic.group.json#"
					case schedule = "http://alertme.com/schema/json/node.class.synthetic.control.device.uniform.scheduler.json#"
					
					case other1 =
						"http://alertme.com/schema/json/node.class.synthetic.zonename.initializer.json#"
					
					case other2 =
						"http://alertme.com/schema/json/node.class.synthetic.daylight.json#"
					
					case other3 =
						"http://alertme.com/schema/json/node.class.synthetic.fake.occupancy.json#"
					
					case other4 =
						"http://alertme.com/schema/json/node.class.synthetic.binary.sensor.device.uniform.scheduler.json#"
					
					case other5 =
						"http://alertme.com/schema/json/node.class.synthetic.buffered.binary.sensor.device.uniform.scheduler.json#"
					
					case other6 =
						"http://alertme.com/schema/json/node.class.synthetic.binary.control.device.uniform.scheduler.json#"
					
					case other7 =
						"http://alertme.com/schema/json/node.class.synthetic.testing.mirror.device.json#"
					
					case other8 =
						"http://alertme.com/schema/json/node.class.synthetic.philips.hue.bridge.json#"
					
					case other9 =
						"http://alertme.com/schema/json/node.class.synthetic.mqtt.camera.mirror.device.json#"
					
					func typeName() -> String {
						switch self {
						case .light: return "Light"
						case .colorLight: return "Color light"
						case .action: return "Action"
						case .group: return "Group"
						case .hub: return "Hub"
						case .schedule: return "Schedule"
						case _: return "Other"
						}
					}
				}
			}
			struct Presence: JSONCodable {
				let reportedValue: Value
				
				enum Value: String, JSONCodable {
					case present = "PRESENT"
					case absent = "ABSENT"
				}
			}
			struct LastSeen: JSONCodable {
				let reportedValue: String
			}
			struct State: JSONCodable {
				let reportedValue: Value
				let targetValue: Value
				
				enum Value: String, JSONCodable {
					case on = "ON"
					case off = "OFF"
				}
			}
			struct Brightness: JSONCodable {
				let reportedValue: Int
				let targetValue: Int
			}
		}
	}
}
