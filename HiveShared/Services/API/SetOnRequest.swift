//
//  SetOnRequest.swift
//  HiveShared
//
//  Created by James Froggatt on 12.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import Foundation

struct SetOnRequest: JSONCodable {
	let status: State.Status
}

typealias SetOnResponse = SetOnRequest
