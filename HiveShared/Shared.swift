//
//  Shared.swift
//  Hive
//
//  Created by James Froggatt on 22.09.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

#if canImport(UIKit)
import UIKit

public extension UIViewController {
	private func showError(title: String, description: String) {
		let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		self.present(alert, animated: true)
	}
	func showError(_ error: Error, domain: String) {
		self.showError(
			title: domain + " " + ((error as? ErrorResponse.Error)?.code ?? ""),
			description: (error as? ErrorResponse.Error)?.title ?? error.localizedDescription
		)
	}
}
#endif

public extension RawRepresentable where Self: LosslessStringConvertible {
	init?(rawValue: String) {self.init(rawValue)}
}
public extension LosslessStringConvertible where Self: RawRepresentable, Self.RawValue == String {
	var description: String {return rawValue}
}

//JSONCodable

public protocol JSONCodable: Codable {}
public extension JSONCodable {
	init?(data: Data) {
		do {
			self = try JSONDecoder().decode(Self.self, from: data)
		} catch {
			return nil
		}
	}
	func json() -> Data {
		do {
			return try JSONEncoder().encode(self)
		} catch {
			fatalError(error.localizedDescription)
		}
	}
}
