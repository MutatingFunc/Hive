//
//  LoginCredentials.swift
//  Hive
//
//  Created by James Froggatt on 04.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import Foundation
import Security

public enum KeychainError: Error {
	public static let domain = "Keychain"
	case noPassword
	case unexpectedPasswordData
	case unhandledError(status: OSStatus)
}
private let hiveWebURL = "https://my.hivehome.com/"

public struct LoginCredentials {
	public struct Username: Codable, RawRepresentable, LosslessStringConvertible {
		public var rawValue: String
		public init(_ rawValue: String) {self.rawValue = rawValue}
	}
	public struct Password: Codable, RawRepresentable, LosslessStringConvertible {
		public var rawValue: String
		public init(_ rawValue: String) {self.rawValue = rawValue}
	}
	public var username: Username
	public var password: Password
	public init(username: String, password: String) {
		self.username = Username(username)
		self.password = Password(password)
	}
	
	private static func keychainSearchQuery(username: String? = nil) -> [String: Any] {
		var query: [String: Any] = [
			kSecClass as String: kSecClassInternetPassword,
			kSecAttrServer as String: hiveWebURL
		]
		if let username = username {
			query[kSecAttrAccount as String] = username
		}
		return query
	}
	public static func savedCredentials(username: String? = nil) throws -> LoginCredentials {
		var query = keychainSearchQuery(username: username)
		query[kSecMatchLimit as String] = kSecMatchLimitOne
		query[kSecReturnAttributes as String] = true
		query[kSecReturnData as String] = true
		var item: CFTypeRef?
		let status = SecItemCopyMatching(query as CFDictionary, &item)
		guard status != errSecItemNotFound else {throw KeychainError.noPassword}
		guard status == errSecSuccess else {throw KeychainError.unhandledError(status: status)}
		guard let existingItem = item as? [String: Any],
			let passwordData = existingItem[kSecValueData as String] as? Data,
			let password = String(data: passwordData, encoding: String.Encoding.utf8),
			let username = existingItem[kSecAttrAccount as String] as? String
		else {
			throw KeychainError.unexpectedPasswordData
		}
		return LoginCredentials(username: username, password: password)
	}
	
	public func saveToKeychain() throws {
		do {
			try addToKeychain()
		} catch KeychainError.unhandledError(status: errSecDuplicateItem) {
			try updateKeychain()
		}
	}
	
	private func updateKeychain() throws {
		let passwordData = password.rawValue.data(using: .utf8)!
		let query = LoginCredentials.keychainSearchQuery(username: self.username.rawValue)
		let status = SecItemUpdate(query as CFDictionary, [
			kSecValueData: passwordData
		] as CFDictionary)
		guard status != errSecItemNotFound else {throw KeychainError.noPassword}
		guard status == errSecSuccess else {throw KeychainError.unhandledError(status: status)}
	}
	private func addToKeychain() throws {
		let passwordData = password.rawValue.data(using: .utf8)!
		let query: [String: Any] = [
			kSecClass as String: kSecClassInternetPassword,
			kSecAttrServer as String: hiveWebURL,
			kSecAttrAccount as String: username.rawValue,
			kSecValueData as String: passwordData
		]
		let status = SecItemAdd(query as CFDictionary, nil)
		guard status == errSecSuccess else {throw KeychainError.unhandledError(status: status)}
	}
}
