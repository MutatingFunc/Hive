//
//  Shared.swift
//  Hive
//
//  Created by James Froggatt on 22.09.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import Foundation

public extension RawRepresentable where Self: LosslessStringConvertible {
	init?(rawValue: String) {self.init(rawValue)}
}
public extension LosslessStringConvertible where Self: RawRepresentable, Self.RawValue == String {
	var description: String {return rawValue}
}

//JSONCodable

public protocol JSONCodable: Codable {}
public extension JSONCodable {
	init(data: Data) throws {
		self = try JSONDecoder().decode(Self.self, from: data)
	}
	func json() -> Data {
		do {
			return try JSONEncoder().encode(self)
		} catch {
			fatalError(error.localizedDescription)
		}
	}
}
