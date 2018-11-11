//
//  TodayViewController.swift
//  HiveWidget
//
//  Created by James Froggatt on 11.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import UIKit
import NotificationCenter

import HiveShared

class TodayViewController: UIViewController, NCWidgetProviding {
	@IBOutlet private var tableView: UITableView!
	@IBOutlet private var failureLabel: UILabel!
	
	var deviceList: DeviceList? {
		didSet {
			let devices = deviceList?.devices.prefix(while: {$0.isFavourite()}) ?? []
			let actions = (deviceList?.actions as [Device]?)?.prefix(while: {$0.isFavourite()}) ?? []
			var result = Array(devices)
			result.append(contentsOf: actions)
			self.tableView.isHidden = result.isEmpty
			self.failureLabel.isHidden = result.isEmpty == false
			self.devices = result
		}
	}
	
	var devices: [Device] = [] {
		didSet {
			if self.isViewLoaded {
				self.tableView.reloadData()
				self.preferredContentSize = tableView.contentSize
			}
		}
	}
	
	func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
		self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
		self.failureLabel.isHidden = true
		self.tableView.isHidden = true
		self.tryGetDevices(
			success: {deviceList in
				self.deviceList = deviceList
				print("Success")
				completionHandler(.newData)
			},
			failure: {error in
				print("Error: \(error)")
				self.failureLabel.isHidden = false
				self.failureLabel.text = error.localizedDescription
				completionHandler(.failed)
			}
		)
	}
	
	func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
		tableView.reloadData()
		self.preferredContentSize = tableView.contentSize
	}
	
	func tryGetDevices(login: Login = Login(), success: @escaping (DeviceList) -> (), failure: @escaping (Error) -> ()) {
		do {
			_ = login.login(credentials: try .savedCredentials()) {response in
				switch response {
				case .success(let loginInfo, _):
					success(DeviceList(loginInfo: loginInfo))
				case .error(let error, _):
					failure(error)
				}
			}
		} catch {
			failure(error)
		}
	}
}

extension TodayViewController: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if self.deviceList == nil {
			return 0
		}
		if self.extensionContext?.widgetActiveDisplayMode == .compact {
			return self.devices.isEmpty ? 0 : 1
		}
		return self.devices.count
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let deviceList = self.deviceList!
		switch devices[indexPath.row] {
		case let device as ActionDevice:
			let cell = tableView.dequeueReusableCell(for: indexPath) as ActionCell
			cell.setDevice(deviceList.action(device), delegate: nil)
			return cell
		case let device as ToggleableDevice:
			let cell = tableView.dequeueReusableCell(for: indexPath) as ToggleCell
			cell.setDevice(deviceList.toggle(device), delegate: nil)
			return cell
		case let device:
			let cell = tableView.dequeueReusableCell(for: indexPath) as DefaultDeviceCell
			cell.setDevice(device, delegate: nil)
			return cell
		}
	}
}
